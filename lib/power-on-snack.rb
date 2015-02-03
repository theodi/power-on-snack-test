require 'sinatra'
require_relative './vending-machine'

class PowerOnSnack < Sinatra::Base

  FLAVOURS = [
    'salt-and-vinegar',
    'prawn-cocktail',
    'cheese-and-onion',
    'ready-salted'
  ]

  post '/dispense' do
    if FLAVOURS.include?(params[:flavour])
      VendingMachine.dispense(params[:flavour])
      return 203
    else
      return 400
    end
  end

end
