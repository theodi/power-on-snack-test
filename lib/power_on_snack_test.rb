require 'sinatra'
require 'sinatra/logger'

require_relative './vending_machine'

class PowerOnSnackTest < Sinatra::Base

  register(Sinatra::Logger)

  set :logger_log_file, lambda { "#{settings.root}/../log/#{settings.environment}.log" }
  set :logger_level, :info

  FLAVOURS = VendingMachine.flavours.keys

  get '/' do
    @headlines = CSV.parse(File.read('config/headlines.csv')).map! { |l|
      {
        headline: l[0],
        url: l[1],
        triggered: l[2] == 'true'
      }
    }
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
