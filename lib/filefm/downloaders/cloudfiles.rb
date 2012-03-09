module FileFM
  module Downloaders
    class Cloudfiles
      def self.download(link, opts = {})
        require 'fog'
        require 'fog/rackspace/storage'
        
        uri = URI.parse(link)
        container = uri.host
        object = link.gsub(/^.*#{container}\//, "")
        auth_url = "https://auth.api.rackspacecloud.com/v1.0"

        if (not opts[:username] or not opts[:password])
          raise "Invalid Credentials"
        end
        secure = true
        scheme = secure ? "https" : "http"
        username = opts[:username]
        password = opts[:password]

        #puts "#{scheme}://#{uri.host}/auth/v1.0"
        conn = Fog::Storage.new({
          :provider => 'Rackspace',
          :rackspace_username => username,
          :rackspace_api_key => password
        })

        out = RestClient.get auth_url, 'X-Auth-User' => username, 'X-Auth-Key' => password
        storage_url = out.headers[:x_storage_url]
        auth_token = out.headers[:x_auth_token]
        raise "Error authenticating" unless out.code == 204

        o = {
          :location => nil,
          :size => nil,
          :filename => nil
        }.merge(opts)
        
        @location = o[:location] ||= ""
        @filename = o[:filename]
        progress = 0
        
        headers = {
                    "User-Agent" => "FileFM #{VERSION}",
                    "X-Auth-Token" => auth_token
                   }
        
        c = conn.directories.get container
        raise "Container not found" if c.nil?

        o = c.files.get object
        @size = o.content_length

        uri = URI.parse storage_url 
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.open_timeout = 3 # seconds
        http.read_timeout = 3 # seconds
        path = uri.path + "/#{container}/#{object}"
        request = Net::HTTP::Get.new(path)

        request.initialize_http_header headers

        puts "unknown file size for #{@filename} but downloading..." if @size.nil?
        
        dest_file = opts[:destination] || File.basename(object)

        response = http.request(request) do |response|
          if opts[:progressbar]
            bar = ProgressBar.new("Progress", @size.to_i) unless @size.nil?
            bar.format_arguments=[:title, :percentage, :bar, :stat_for_file_transfer] unless @size.nil?
          end
                
          File.open(dest_file, "wb") do |file|
            response.read_body do |segment|
              if opts[:progressbar]
                progress += segment.length
                bar.set(progress) unless @size.nil?
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
        
