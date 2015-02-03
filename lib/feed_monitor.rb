require 'csv'
require 'httparty'
require 'rss'
require 'open-uri'

class FeedMonitor
  def self.keywords
    c = CSV.read 'config/keywords.csv'
    c.map!{ |i| i.first }
  end

  def self.perform
    url = 'http://feeds.bbci.co.uk/news/rss.xml'
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        keywords.each do |kw|
          trigger(item, kw) if item.title =~ /\b#{kw}\b/
        end
      end
    end
  end

  def self.trigger(item, kw)
    if date_stamp.nil? || item.pubDate > date_stamp
      puts "#{item.title} matched #{kw}"
      File.write(marker, Marshal.dump(item.pubDate))
      HTTParty.post('http://localhost:9292/dispense', query: { flavour: 'prawn-cocktail' })
    end
  end

  def self.marker
    'config/marker.txt'
  end

  def self.date_stamp
    Marshal.load(File.open(marker, 'r')) rescue nil
  end

end
