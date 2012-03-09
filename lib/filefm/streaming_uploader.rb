module FileFM

  # StreamingUploader Adapted by Sergio Rubio <rubiojr@frameos.org>
  #
  # inspired by Opscode Chef StreamingCookbookUploader chef/streaming_cookbook_uploader.rb
  # http://opscode.com
  # 
  # inspired by/cargo-culted from http://stanislavvitvitskiy.blogspot.com/2008/12/multipart-post-in-ruby.html
  # On Apr 6, 2010, at 3:00 PM, Stanislav Vitvitskiy wrote:
  #
  # It's free to use / modify / distribute. No need to mention anything. Just copy/paste and use.
  #
  # Regards,
  # Stan


  require 'net/http'

  class StreamingUploader

    class << self

      def put(to_url, params = {}, &block)
        boundary = '----RubyMultipartClient' + rand(1000000).to_s + 'ZZZZZ'
        parts = []
        content_file = nil
        
        unless params.nil? || params.empty?
          params.each do |key, value|
            if value.kind_of?(File)
              content_file = value
              filepath = value.path
              filename = File.basename(filepath)
              parts << StringPart.new( "--" + boundary + "\r\n" +
                                       "Content-Disposition: form-data; name=\"" + key.to_s + "\"; filename=\"" + filename + "\"\r\n" +
                                       "Content-Type: application/octet-stream\r\n\r\n")
              parts << StreamPart.new(value, File.size(filepath))
              parts << StringPart.new("\r\n")
            else
              parts << StringPart.new( "--" + boundary + "\r\n" +
                                       "Content-Disposition: form-data; Content-Type:application/json; name=\"" + key.to_s + "\"\r\n\r\n")
              parts << StringPart.new(value.to_s + "\r\n")
            end
          end
          parts << StringPart.new("--" + boundary + "--\r\n")
        end
        
        body_stream = MultipartStream.new(parts, block)
        
        url = URI.parse(to_url)
        
        headers = { 'Content-Length' => body_stream.size.to_s, 'Content-Type' => 'application/json' }.merge(params[:headers])

        req = Net::HTTP::Put.new(url.path, headers)
        if ENV["DEBUG"] == "yes"
          puts "HEADERS: " + headers.inspect
          puts "HOST:    " + url.host 
          puts "PORT:    " + url.port.to_s
          puts "PATH:    " + url.path
        end
        
        req.content_length = body_stream.size
        req.content_type = 'multipart/form-data; boundary=' + boundary unless parts.empty?
        req.body_stream = body_stream
        
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == "https"
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.scheme == "https"
        res = http.request(req)
        res
      end
      
    end

    class StreamPart
      def initialize(stream, size)
        @stream, @size = stream, size
      end

      def size
        @size
      end

      # read the specified amount from the stream
      def read(offset, how_much)
        @stream.read(how_much)
      end
    end

    class StringPart
      def initialize(str)
        @str = str
      end
      
      def size
        @str.length
      end

      # read the specified amount from the string startiung at the offset
      def read(offset, how_much)
        @str[offset, how_much]
      end
    end

    class MultipartStream
      def initialize(parts, blk = nil)
        @callback = nil
        if blk
          @callback = blk
        end
        @parts = parts
        @part_no = 0
        @part_offset = 0
      end
      
      def size
        @parts.inject(0) {|size, part| size + part.size}
      end
      
      def read(how_much)
        @callback.call(how_much) if @callback
        return nil if @part_no >= @parts.size

        how_much_current_part = @parts[@part_no].size - @part_offset
        
        how_much_current_part = if how_much_current_part > how_much
                                  how_much
                                else
                                  how_much_current_part
                                end
        
        how_much_next_part = how_much - how_much_current_part

        current_part = @parts[@part_no].read(@part_offset, how_much_current_part)
        
        # recurse into the next part if the current one was not large enough
        if how_much_next_part > 0
          @part_no += 1
          @part_offset = 0
          next_part = read(how_much_next_part)
          current_part + if next_part
                           next_part
                         else
                           ''
                         end
        else
          @part_offset += how_much_current_part
          current_part
        end
      end
    end
    
  end


end

