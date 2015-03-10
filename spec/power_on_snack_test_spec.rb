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
    allow(File).to receive(:read).and_return(File.read('./spec/fixtures/headlines.csv'))
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/MPs say yes to three-person babies/)
    expect(last_response.body).to match(/http:\/\/www.bbc.co.uk\/news\/health-31069173#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa/)
    expect(last_response.body).to match(/<li class="triggered"><span class="timestamp">Tue, 03 Feb 2015 16:34:41 \+00:00<\/span><a href="http:\/\/www.bbc.co.uk\/news\/uk-politics-31099106#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa/)
    expect(last_response.body).to match(/<li class="normal"><span class="timestamp">Tue, 03 Feb 2015 16:19:37 \+00:00<\/span><a href="http:\/\/www.bbc.co.uk\/news\/health-31069173#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa/)
    expect(last_response.body.scan(/<li /).count).to eq(10)
  end

end
