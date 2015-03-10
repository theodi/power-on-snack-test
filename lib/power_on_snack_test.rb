require 'sinatra'
require 'sinatra/logger'

require_relative './vending_machine'

class PowerOnSnackTest < Sinatra::Base

  register(Sinatra::Logger)

  set :public_folder, "#{settings.root}/../public"

  unless settings.environment == "test"
    set :logger_log_file, lambda { "#{settings.root}/../log/#{settings.environment}.log" }
    set :logger_level, :info
  end

  FLAVOURS = VendingMachine.flavours.keys

  get '/' do
    @headlines = CSV.parse(File.read('config/headlines.csv', {encoding: 'ISO-8859-1', mode: 'r'})).map! { |l|
      {
        timestamp: DateTime.parse(l[0]),
        headline: l[1],
        url: l[2],
        triggered: l[3] == 'true'
      }
    }.sort_by { |h| h[:timestamp] }.reverse[0...10] rescue nil

    erb :index
  end

  post '/dispense' do
    if FLAVOURS.include?(params[:flavour])
      logger.info("Dispensing #{params[:flavour]}...")
      message = VendingMachine.instance.dispense(params[:flavour])
      logger.info(message)
      halt 203
    else
      halt 400
    end
  end

end
