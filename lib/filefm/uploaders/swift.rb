module FileFM
  module Uploaders
    class Swift

      def self.upload(source, destination, options)
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

        #puts "#{scheme}://#{uri.host}/auth/v1.0"
        out = RestClient.get "#{scheme}://#{uri.host}/auth/v1.0", 'X-Storage-User' => username, 'X-Storage-Pass' => password
        storage_url = out.headers[:x_storage_url]
        auth_token = out.headers[:x_auth_token]
        raise "Error authenticating" unless out.code == 200
        
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
