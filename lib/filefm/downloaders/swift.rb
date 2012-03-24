module FileFM
  module Downloaders
    class Swift
      def self.download(link, opts = {})
        require 'fog'
        require 'fog/rackspace/storage'
        
        uri = URI.parse(link)
        container = uri.path.split("/")[1]
        object = uri.path.split("/")[2..-1].join("/")

        if (not opts[:username] or not opts[:password])
          raise "Invalid Credentials"
        end
        secure = opts[:secure] == true 
        scheme = secure ? "https" : "http"
        username = opts[:username]
        password = opts[:password]

        #puts "#{scheme}://#{uri.host}/auth/v1.0"
        conn = Fog::Storage.new({
          :provider => 'Rackspace',
          :rackspace_username => username,
          :rackspace_api_key => password,
          :rackspace_auth_url => "#{scheme}://#{uri.host}/auth/v1.0"
                        })


        out = RestClient.get "#{scheme}://#{uri.host}/auth/v1.0", 'X-Storage-User' => username, 'X-Storage-Pass' => password
        storage_url = out.headers[:x_storage_url]
        auth_token = out.headers[:x_auth_token]
        raise "Error authenticating" unless out.code == 200

        o = {
          :location => nil,
          :size => nil,
          :filename => nil
        }.merge(opts)
        
        @link = storage_url + "#{uri.path}"
        @size = o[:size]
        @location = o[:location] ||= ""
        @filename = o[:filename]
        @progress = 0
        
        headers = {
                    "User-Agent" => "FileFM #{VERSION}",
                    "X-Auth-Token" => auth_token
                   }

        uri = URI.parse storage_url + uri.path
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.open_timeout = 3 # seconds
        http.read_timeout = 3 # seconds
        request = Net::HTTP::Get.new(uri.request_uri)

        request.initialize_http_header headers

        container = conn.directories.get container
        raise "Container not found" if container.nil?

        object = container.files.get object
        @size = object.content_length
        
        puts "unknown file size for #{@filename} but downloading..." if @size.nil?
        #puts @link.to_s
        
        if opts[:output]
          dest_file = opts[:output]
        else
          dest_file = @location + (@filename ||= File.basename(uri.path))
        end
        response = http.request(request) do |response|
          if opts[:progressbar]
            bar = ProgressBar.new("Progress", @size.to_i) unless @size.nil?
            bar.format_arguments=[:title, :percentage, :bar, :stat_for_file_transfer] unless @size.nil?
          end
                
          File.open(dest_file, "wb") do |file|
            response.read_body do |segment|
              if opts[:progressbar]
                @progress += segment.length
                bar.set(@progress) unless @size.nil?
              end
              file.write(segment)
            end
          end
        end

        FileUtils.rm dest_file unless response.is_a? Net::HTTPOK
        raise "Error downlading file: #{response.class.to_s}" unless response.is_a? Net::HTTPOK
      end
    end
  end
end
        
