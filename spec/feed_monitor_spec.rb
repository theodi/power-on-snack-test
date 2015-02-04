require 'spec_helper'

describe FeedMonitor do

  before(:each) do
    File.write('config/marker.txt', '')
    FileUtils.rm_f 'config/headlines.csv'
    FileUtils.touch 'config/headlines.csv'
    allow(Trigger).to receive(:perform)
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

    my_csv = CSV.parse(File.read('config/headlines.csv'))

    expect(File).to exist 'config/headlines.csv'
    expect(my_csv.count).to eq 86

    expect(my_csv[0][0].strip).to eq 'Tue, 03 Feb 2015 16:19:37 +0000'
    expect(my_csv[1][0].strip).to eq 'Tue, 03 Feb 2015 16:10:39 +0000'

    expect(my_csv[0][1].strip).to eq 'MPs say yes to three-person babies'
    expect(my_csv[1][1].strip).to eq 'Lee to publish Mockingbird \'sequel\''

    expect(my_csv[0][2].strip).to eq 'http://www.bbc.co.uk/news/health-31069173#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa'
    expect(my_csv[1][2].strip).to eq 'http://www.bbc.co.uk/news/entertainment-arts-31118355#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa'

    expect(my_csv[0][3].strip).to eq 'false'
    expect(my_csv[1][3].strip).to eq 'false'
  end

  it 'only dispenses once for a given match' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)

    FeedMonitor.perform

    expect(HTTParty).to_not receive(:post).with('http://localhost:9292/dispense', body: { flavour: String })

    FeedMonitor.perform
  end

  it 'sends a trigger when a match occurs' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)

    expect(Trigger).to receive(:perform).with('Purely to trigger crisps - recession', String)

    FeedMonitor.perform
  end

end
