require 'rspec/core/rake_task'
require_relative './lib/feed_monitor'

RSpec::Core::RakeTask.new(:spec)

task :monitor do
  FileUtils.touch 'config/headlines.csv'
  FeedMonitor.perform
end

task :default => :spec
