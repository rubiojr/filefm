require 'filefm/uploaders/swift.rb'
require 'filefm/downloaders/swift.rb'

Shindo.tests('Swift') do

  tests("insecure upload") do
    test_file = "/tmp/swift-upload-test"
    returns(true, 'test file') do
      `dd if=/dev/zero of=#{test_file} bs=1k count=128 2>/dev/null`
      FileFM::Uploaders::Swift.upload(test_file,
                                      "swift://#{swift_server}/#{swift_test_container}/#{File.basename(test_file)}", 
                                      { 
                                        :username => "#{swift_username}",
                                        :password => "#{swift_password}",
                                        :progressbar => true,
                                        :secure => false
                                      })
      true
    end
  end

  tests("insecure download") do
    dest_file = "/tmp/swift-download-test"
    test_file = "/tmp/swift-upload-test"
    returns(true, 'download ok') do
      FileFM::Downloaders::Swift.download(
        "swift://#{swift_server}/#{swift_test_container}/#{File.basename(test_file)}", 
        { 
          :output => dest_file,
          :username => "#{swift_username}",
          :password => "#{swift_password}",
          :progressbar => true,
          :secure => false
        }
      )
      File.exist?(dest_file)
    end
    returns(true, 'MD5 matches') do
      `md5sum #{dest_file}`.split()[0] == `md5sum #{test_file}`.split()[0]
    end
  end

end

