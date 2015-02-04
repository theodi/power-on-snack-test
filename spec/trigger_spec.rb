require 'spec_helper'

describe Trigger do

  it 'sends a message to Mandrill' do
    expect_any_instance_of(Mandrill::Messages).to receive(:send).with({
      :subject => "IFTTT Trigger",
      :from_name => "ops@theodi.org",
      :text => "Headline Headline dispensed Prawn Cocktail",
      :to => [
        {
          :email=> "trigger@recipe.ifttt.com",
          :name=> "trigger@recipe.ifttt.com"
        }
      ],
      :from_email => "ops@theodi.org"
    })

    Trigger.perform("Headline", "prawn-cocktail")
  end

  it 'humanizes flavours correctly' do
    {
      'prawn-cocktail' => "Prawn Cocktail",
      'salt-and-vinegar' => "Salt & Vinegar",
      'ready-salted' => "Ready Salted",
      'cheese-and-onion' => "Cheese & Onion"
    }.each do |input, output|
      expect(Trigger.humanize(input)).to eq(output)
    end
  end

end
