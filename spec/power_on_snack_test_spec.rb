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

  it "displays a list of the latest headlines" do
    allow(File).to receive(:read).and_return(File.read("./spec/fixtures/headlines.csv"))
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/VIDEO: Vatican priests who are also recession astrophysicists/)
    expect(last_response.body).to match(/http:\/\/www.bbc.co.uk\/news\/magazine-31051635#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa/)
    expect(last_response.body).to match(/<li class="triggered"><a href="http:\/\/www.bbc.co.uk\/news\/magazine-31051635/)
    expect(last_response.body).to match(/<li class="normal"><a href="http:\/\/www.bbc.co.uk\/news\/uk-3110437/)
  end

end
