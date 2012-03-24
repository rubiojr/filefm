require 'filefm'

def test_config
  File.join(File.dirname(__FILE__), 'config.yml')
end

def swift_server
  ENV["SWIFT_SERVER"]
end

def swift_username
  u = ENV["SWIFT_USERNAME"]
  u
end

def swift_password
  ENV["SWIFT_PASSWORD"]
end

def swift_test_container
  ENV["SWIFT_TEST_CONTAINER"] || "filefm-test"
end

def swift_keystone_url
  ENV["SWIFT_KEYSTONE_URL"] 
end
