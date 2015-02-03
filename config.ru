require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'lib/power_on_snack_test.rb')

run PowerOnSnackTest
