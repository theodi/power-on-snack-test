require 'sinatra'
require_relative './vending_machine'

class PowerOnSnackTest < Sinatra::Base

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
      VendingMachine.instance.dispense(params[:flavour])
      halt 203
    else
      halt 400
    end
  end

end
