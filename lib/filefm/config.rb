module FileFM
  require 'yaml'

  class Config 

    def self.file=(file)
      @file = file
    end
    
    def self.provider=(provider)
      @provider = provider
    end

    def self.provider
      @provider || :default
    end

    def self.file
      @file || ENV["HOME"] + "/.filefm"
    end

    def self.load
      return nil if not File.exist?(file)
      @config ||= YAML.load_file file
    end

    def self.[](key)
      self.load[provider][key]
    end

  end

end
