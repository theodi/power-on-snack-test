require 'sinatra'
require_relative './vending_machine'

class PowerOnSnack < Sinatra::Base

  FLAVOURS =  VendingMachine.flavours.keys

  post '/dispense' do
    if FLAVOURS.include?(params[:flavour])
      VendingMachine.dispense(params[:flavour])
      return 203
    else
      return 400
    end
  end

end
