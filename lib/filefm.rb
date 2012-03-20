require 'progressbar'
require 'net/http'
require 'uri'
require 'filefm/streaming_uploader'
require 'filefm/config'
require 'restclient'
require 'fileutils'
require 'multi_json'
require 'fog'
require 'logger'

module FileFM

  if !defined? Log or Log.nil?
    Log = Logger.new($stdout)
    Log.formatter = proc do |severity, datetime, progname, msg|
        "[FileFM] #{severity}: #{msg}\n"
    end
    Log.level = Logger::INFO unless ENV["DEBUG"].eql? "yes"
    Log.debug "Initializing logger"
  end

  VERSION="0.1"

  def self.download(link, opts={})
    uri = URI.parse link
    if uri.scheme =~ /^http/
      require 'filefm/downloaders/http'
      FileFM::Downloaders::HTTP.download link, opts
    elsif uri.scheme =~ /^swift/
      require 'filefm/downloaders/swift'
      FileFM::Downloaders::Swift.download link, opts
    elsif uri.scheme =~ /^cloudfiles/
      require 'filefm/downloaders/cloudfiles'
      FileFM::Downloaders::Cloudfiles.download link, opts
    end

  end

  def self.upload(source, destination, options = {})
    uri = URI.parse destination 
    if uri.scheme =~ /^swift/
      uri = URI.parse(destination)
        # swift://swift-server/container/object
        require 'filefm/uploaders/swift'
        FileFM::Uploaders::Swift.upload source, destination, options
    elsif uri.scheme =~ /^cloudfiles/
        require 'filefm/uploaders/cloudfiles'
        FileFM::Uploaders::Cloudfiles.upload source, destination, options
    end
  end

end

