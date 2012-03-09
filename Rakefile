# encoding: utf-8

require 'rubygems'
require 'filefm'

require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.version = FileFM::VERSION
  gem.name = "filefm"
  gem.homepage = "http://github.com/rubiojr/filefm"
  gem.license = "MIT"
  gem.summary = %Q{Simple library to download/upload files}
  gem.description = %Q{Simple library to download/upload files}
  gem.email = "rubiojr@frameos.org"
  gem.authors = ["Sergio Rubio"]
  # dependencies defined in Gemfile
  gem.add_runtime_dependency 'clamp'
  gem.add_runtime_dependency 'fog'
  gem.add_runtime_dependency 'progressbar'
  gem.add_runtime_dependency 'rest-client'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :build
