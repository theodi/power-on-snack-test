require 'mandrill'
require 'dotenv'

Dotenv.load

class Trigger

  def self.perform(title, flavour)
    mandrill.messages.send message("Headline #{title} dispensed #{humanize(flavour)}")
  end

  def self.mandrill
    Mandrill::API.new
  end

  def self.message(text)
    {
      :subject => "IFTTT Trigger",
      :from_name => "ops@theodi.org",
      :text => text,
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
