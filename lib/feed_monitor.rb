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
          if item.title =~ /\b#{kw}\b/
            puts "#{item.title} matched #{kw}"
            HTTParty.post('http://localhost:9292/dispense', query: { flavour: 'prawn-cocktail' })
          end
        end
      end
    end
  end
end
