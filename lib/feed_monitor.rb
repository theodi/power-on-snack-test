require 'csv'
require 'httparty'
require 'rss'
require 'open-uri'
require 'logger'
require_relative 'vending_machine'
require_relative 'trigger'

class FeedMonitor

  FileUtils.mkdir_p 'log'
  FileUtils.touch 'log/monitor.log'
  LOG = Logger.new('log/monitor.log')
  LOG.level = Logger::INFO

  def self.keywords
    c = CSV.read 'config/keywords.csv'
    c.map!{ |i| i.first }
  end

  def self.flavours
    VendingMachine.flavours
  end

  def self.perform
    LOG.info "I am running now - looking for headlines..."
    last_run_headlines = (CSV.read('config/headlines.csv', {encoding: 'ISO-8859-1'})).map { |line| line[0] }
    headlines = []
    url = 'http://feeds.bbci.co.uk/news/rss.xml'
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        triggered = false
        unless last_run_headlines.include? item.title
          keywords.each do |kw|
            if item.title =~ /\b#{kw}\b/
              trigger(item, kw)
              triggered = true
            end
          end
        end

        headlines << "\"#{item.pubDate}\",\"#{item.title}\",#{item.link},#{triggered}"
      end
    end

    out = File.open 'config/headlines.csv', 'w'
    headlines.each do |headline|
      out.write headline
      out.write "\n"
    end
    out.close
  end

  def self.trigger(item, kw)
    if date_stamp.nil? || item.pubDate > date_stamp
      LOG.info "'#{item.title}' matched '#{kw}'"
      flav = self.flavours.keys.sample
      LOG.info "Dispensing #{flav}"
      File.write(marker, Marshal.dump(item.pubDate))
      HTTParty.post('http://localhost:9292/dispense', body: { flavour: flav })
      Trigger.perform(item.link, flav)
    end
  end

  def self.marker
    'config/marker.txt'
  end

  def self.date_stamp
    Marshal.load(File.open(marker, 'r')) rescue nil
  end

end
