require 'spec_helper'

describe PowerOnSnackTest do

  it "returns 404 when flavour does not exist" do
    post 'dispense', flavour: 'smoky-bacon' # I so wish we had these
    expect(last_response.status).to eq(400)
  end

  it "runs the vending machine when an exant flavour is requested" do
    expect_any_instance_of(VendingMachine).to receive(:dispense).with('cheese-and-onion')
    post 'dispense', flavour: 'cheese-and-onion'
    expect(last_response.status).to eq(203)
  end

end
