require 'spec_helper'

describe FeedMonitor do

  before(:each) do
    File.write('config/marker.txt', '')
    FileUtils.rm_f 'config/headlines.csv'
    FileUtils.touch 'config/headlines.csv'
  end

  it 'has keywords' do
    expect(FeedMonitor.keywords[0]).to eq 'administration'
  end

  it 'triggers a crisp dispense event on a keyword match' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))

    expect(HTTParty).to receive(:post).with('http://localhost:9292/dispense', body: { flavour: String })

    FeedMonitor.perform
  end

  it 'calls for a random crisp flavour on a CDE' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    expect(HTTParty).to receive(:post) do |url, hash|
      expect(url).to eq 'http://localhost:9292/dispense'
      expect([
        'prawn-cocktail',
        'salt-and-vinegar',
        'cheese-and-onion',
        'ready-salted'
      ]).to include hash[:body][:flavour]
    end

    FeedMonitor.perform
  end

  it 'records the headlines' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss-complete.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)

    FeedMonitor.perform

    my_csv = File.readlines('config/headlines.csv')

    expect(File).to exist 'config/headlines.csv'
    expect(my_csv.count).to eq 86

    expect(my_csv[0].split(',')[2].strip).to eq 'true'
    expect(my_csv[1].split(',')[2].strip).to eq 'false'
  end

  it 'only dispenses once for a given match' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)

    FeedMonitor.perform

    expect(HTTParty).to_not receive(:post).with('http://localhost:9292/dispense', body: { flavour: String })

    FeedMonitor.perform

  end

end
