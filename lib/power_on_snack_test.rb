require 'sinatra'
require_relative './vending_machine'

class PowerOnSnackTest < Sinatra::Base

  FLAVOURS =  VendingMachine.flavours.keys

  post '/dispense' do
    if FLAVOURS.include?(params[:flavour])
      VendingMachine.dispense(params[:flavour])
      halt 203
    else
      halt 400
    end
  end

end
