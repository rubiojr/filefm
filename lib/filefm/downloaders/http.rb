module FileFM
  module Downloaders
    class HTTP
      def self.download(link, opts = {})
        o = {
          :location => nil,
          :size => nil,
          :filename => nil
        }.merge(opts)
        
        @link = link
        @size = o[:size]
        @location = o[:location] ||= ""
        @filename = o[:filename]
        @progress = 0
        
        uri = URI.parse(@link.to_s)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.open_timeout = 3 # seconds
        http.read_timeout = 3 # seconds
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header({"User-Agent" => "FileFM #{VERSION}"})

        head = http.request_head(URI.escape(uri.request_uri))
        case head
        when Net::HTTPForbidden
          @size = nil #no content-length no progress bar
        else
          @size = head['content-length'] if @size.nil? && head['content-length'].to_i > 1024
        end
        
        #puts "unknown file size for #{@filename} but downloading..." if @size.nil?
        #puts @link.to_s
        
        dest_file = @location + (@filename ||= File.basename(uri.path))
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
        
