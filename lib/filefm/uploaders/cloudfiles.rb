module FileFM
  module Uploaders
    class Cloudfiles 

      def self.upload(source, destination, options)
        uri = URI.parse(destination)
        container = uri.host
        object = uri.path

        if (not options[:username] or not options[:password])
          raise "Invalid Credentials"
        end
        secure = options[:secure] == true 
        scheme = "https"
        username = options[:username]
        password = options[:password]

        #puts "#{scheme}://#{uri.host}/auth/v1.0"
        out = RestClient.get "#{scheme}://auth.api.rackspacecloud.com/v1.0", 'X-Auth-User' => username, 'X-Auth-Key' => password
        storage_url = out.headers[:x_storage_url]
        auth_token = out.headers[:x_auth_token]
        raise "Error authenticating" unless out.code == 204
        
        begin
          out = RestClient.get storage_url + "/#{container}", 'X-Auth-Token' => auth_token
        rescue
          raise "Error accessing the container: #{container}"  
        end

        if options[:progressbar]
          pbar = ProgressBar.new "Progress", 100
          fsize = File.size(source)
          count = 0
        end

        headers = { 'X-Auth-Token' => auth_token, 'Content-Type' => "application/json" }
        path = storage_url + "/#{container}#{object}"

        res = FileFM::StreamingUploader.put(
            path,
            :headers => { 'X-Auth-Token' => auth_token }, :file => File.open(source) 
        ) do |size|
            if block_given?
              yield size
            elsif options[:progressbar]
             count += size
             per = (100*count)/fsize 
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
