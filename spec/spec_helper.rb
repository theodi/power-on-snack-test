require 'coveralls'
Coveralls.wear!

require 'rack/test'
require File.expand_path '../../lib/power-on-snack.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() PowerOnSnack end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
