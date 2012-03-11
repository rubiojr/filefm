Shindo.tests('Test Config') do

  def set_file f
    FileFM::Config.file = f
  end

  tests("checking settings") do
    returns(true, 'default file') do
      FileFM::Config.file = nil
      FileFM::Config.file == ENV["HOME"] + '/.filefm'
    end
    returns(true, 'changed file') do
      FileFM::Config.file =  '/foo/bar'
      FileFM::Config.file == '/foo/bar'
    end
    returns(true, 'default provider is default') do
      FileFM::Config.provider == :default
    end
    returns(true, 'set the provider to testing') do
      FileFM::Config.provider = :testing
      FileFM::Config.provider == :testing
    end
  end

  tests("check loading") do
    returns(true, 'with non existent file') do
      FileFM::Config.file =  '/foo/bar'
      FileFM::Config.load.nil? 
    end
    returns(true, 'with valid file returns Hash') do
      FileFM::Config.file =  test_config
      FileFM::Config.load.kind_of? Hash
    end
  end

  tests("config keys") do
    FileFM::Config.file =  test_config

    returns true, 'have valid swift_user key' do
      FileFM::Config[:swift_user] == 'admin:admin'
    end
    returns true, 'have valid swift_password key' do
      FileFM::Config[:swift_user] == 'admin:admin'
    end

  end

end

