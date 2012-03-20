module FileFM
  module Uploaders
    class Swift

      def self.authenticate_keystone(username, tenant, api_key, auth_url)
        Log.debug "Using Swift keystone authentication"
        rackspace_auth_url = auth_url
        uri = URI.parse(rackspace_auth_url)
        connection = Fog::Connection.new(rackspace_auth_url, false)
        req_body= {
          'auth' => {
            'passwordCredentials'  => {
              'username' => username,
              'password' => api_key
            }
          }
        }
        req_body['auth']['tenantName'] = tenant

        response = connection.request({
          :expects  => [200, 204],
          :headers => {'Content-Type' => 'application/json'},
          :body  => MultiJson.encode(req_body),
          :host     => uri.host,
          :method   => 'POST',
          :path     =>  (uri.path and not uri.path.empty?) ? uri.path : 'v2.0'
        })
        body=MultiJson.decode(response.body)

        if svc = body['access']['serviceCatalog'].detect{ |x| x['name'] == 'swift' }
          mgmt_url = svc['endpoints'].detect{|x| x['publicURL']}['publicURL']
          token = body['access']['token']['id']
          r = {
            "X-Storage-Url" => mgmt_url,
            "X-Auth-Token" => token,
            "X-Server-Management-Url" => svc['endpoints'].detect{|x| x['adminURL']}['adminURL']
          } 
          return r
        else
          raise "Unable to parse service catalog."
        end
      end

      def self.upload(source, destination, options = {})
        uri = URI.parse(destination)
        if uri.path.split("/").size == 2
          uri.path = File.join(uri.path,File.basename(source))
        end
        if (not options[:username] or not options[:password])
          raise "Invalid Credentials"
        end
        secure = options[:secure] == true 
        scheme = secure ? "https" : "http"
        username = options[:username]
        password = options[:password]

        if options[:auth_url]
          auth_url = options[:auth_url]
          username,tenant = username.split(":")
          out = authenticate_keystone(username, tenant, password, auth_url)
          storage_url = out["X-Storage-Url"]
          auth_token = out["X-Auth-Token"]
        else
          Log.debug "Using Swift legacy auth"
          Log.debug "Legacy auth URL #{scheme}://#{uri.host}/auth/v1.0"
          out = RestClient.get "#{scheme}://#{uri.host}/auth/v1.0", 'X-Storage-User' => username, 'X-Storage-Pass' => password
          storage_url = out.headers[:x_storage_url]
          auth_token = out.headers[:x_auth_token]
          raise "Error authenticating" unless out.code == 200
        end

        Log.debug "authentication OK"
        Log.debug "X-Storage-Url: #{storage_url}"

        begin
          container = "#{uri.path.split("/")[1]}"
          out = RestClient.get storage_url + "/#{container}", 'X-Storage-User' => username, 'X-Auth-Token' => auth_token
        rescue
          raise "Error accessing the container: #{container}"  
        end

        if options[:progressbar]
          pbar = ProgressBar.new "Progress", 100
          fsize = File.size(source)
          count = 0
        end

        res = FileFM::StreamingUploader.put(
            storage_url + uri.path,
            :headers => { 'X-Auth-Token' => auth_token }, :file => File.open(source) 
        ) do |size|
            if block_given?
              yield size
            elsif options[:progressbar]
             count += size
             per = (100*count)/fsize 
             per = 100 if per > 100
             pbar.set per
            else
            end
          end
        if options[:progressbar]
          pbar.finish
        end
      end

    end
  end
end
