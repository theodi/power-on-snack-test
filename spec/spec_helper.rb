require 'coveralls'
Coveralls.wear!

require 'rack/test'
require File.expand_path '../../lib/power_on_snack_test.rb', __FILE__
require File.expand_path '../../lib/feed_monitor.rb', __FILE__

require 'webmock/rspec'

module RSpecMixin
  include Rack::Test::Methods
  def app() PowerOnSnackTest end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
