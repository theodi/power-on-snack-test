require 'mandrill'
require 'dotenv'

Dotenv.load

class Trigger

  def self.perform(link, flavour)
    mandrill.messages.send email(link, flavour)
  end

  def self.mandrill
    Mandrill::API.new
  end

  def self.message(flavour)
    greeting(humanize(flavour)).sample
  end

  def self.greeting(flavour)
    [
      "Who has no thumbs and just dispensed a packet of #{flavour} crisps? This machine",
      "Oh hai! You'll never guess what - I've just dispensed a packet of #{flavour} crisps",
      "Check me out - I've just gone and dropped the finest packet of #{flavour} crisps you'll ever taste",
      "Who likes #{flavour} crisps? 'Cos I've just dispensed a packet of them in my drawer"
    ]
  end

  def self.email(link, flavour)
    {
      :subject => message(flavour),
      :from_name => "ops@theodi.org",
      :text => link,
      :to => [
        {
          :email=> "trigger@recipe.ifttt.com",
          :name=> "trigger@recipe.ifttt.com"
        }
      ],
      :from_email => "ops@theodi.org"
    }
  end

  def self.humanize(flavour)
    flavour.split("-").map { |s| s.capitalize }.join(" ").gsub("And", "&")
  end

end
