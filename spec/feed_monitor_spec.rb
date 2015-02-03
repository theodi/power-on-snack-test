require 'spec_helper'

describe FeedMonitor do

  before(:each) do
    File.write('config/marker.txt', '')
  end

  it 'has keywords' do
    expect(FeedMonitor.keywords[0]).to eq 'administration'
  end

  it 'triggers a crisp dispense event on a keyword match' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))

    expect(HTTParty).to receive(:post).with('http://localhost:9292/dispense', body: { flavour: String })

    FeedMonitor.perform
  end

  it 'writes the last triggered pubDate to the marker file' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)

    expect(File).to receive(:write).with('config/marker.txt', Marshal.dump(Time.parse("Tue, 03 Feb 2015 14:42:28 GMT")))
    FeedMonitor.perform
  end

  it 'does not trigger a crisp dispense event if pubDate is less than the marker' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss.xml'))
    File.write('config/marker.txt', Marshal.dump(Time.parse('Tue, 03 Feb 2015 14:42:28 GMT')))

    expect(HTTParty).to_not receive(:post)
    FeedMonitor.perform
  end

  it 'triggers a new feed item when the marker is present' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss-new.xml'))
    File.write('config/marker.txt', Marshal.dump(Time.parse('Tue, 03 Feb 2015 14:42:28 GMT')))

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

  it 'records the last 10 headlines' do
    stub_request(:get, 'http://feeds.bbci.co.uk/news/rss.xml').to_return(body: File.open('spec/fixtures/rss-complete.xml'))
    stub_request(:post, "http://localhost:9292/dispense").to_return(status: 200)
    FileUtils.rm 'config/headlines.csv'

    FeedMonitor.perform

    my_csv = File.readlines('config/headlines.csv')

    expect(File).to exist 'config/headlines.csv'
    expect(my_csv.count).to eq 10

    expect(my_csv[0].split(',')[2].strip).to eq 'true'
    expect(my_csv[1].split(',')[2].strip).to eq 'false'
  end

end
