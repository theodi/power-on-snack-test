require 'spec_helper'

describe PowerOnSnack do

  it "returns 404 when flavour does not exist" do
    post 'dispense', flavour: 'smoky-bacon' # I so wish we had these
    expect(last_response.status).to eq(404)
  end

  it "runs the vending machine when an exant flavour is requested" do
    expect(VendingMachine).to receive(:dispense).with('cheese-and-onion')
    post 'dispense', flavour: 'cheese-and-onion'
    expect(last_response.status).to eq(200)
  end

end
