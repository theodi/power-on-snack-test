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
      return 200
    else
      return 404
    end
  end

end
