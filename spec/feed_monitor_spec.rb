require 'spec_helper'

describe FeedMonitor do
  it 'has keywords' do
    expect(FeedMonitor.keywords[0]).to eq 'administration'
  end

  it 'triggers a crisp dispense event on a keyword match' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))

    expect(HTTParty).to receive(:post).with('http://localhost:9292/dispense', query: { flavour: 'prawn-cocktail' })

    FeedMonitor.perform
  end
end
