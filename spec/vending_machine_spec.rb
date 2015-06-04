require 'spec_helper'

class VendingMachine

  def reset!
    @arduino = nil
  end

end

describe VendingMachine do

  before(:each) do
    @arduino = instance_double("ArduinoFirmata::Arduino")
    allow(ArduinoFirmata).to receive(:connect).with("/dev/ttyUSB0")
                                              .and_return(@arduino)
  end

  after(:each) do
    VendingMachine.instance.reset!
  end

  it "sends a message to one of the correct pins" do
    expect(@arduino).to receive(:digital_write) do |num, truthy|
      expect([6, 5, 7]).to include num
      expect(truthy).to eq(true)
    end
    expect(@arduino).to receive(:digital_write).at_least(1).times

    VendingMachine.instance.dispense('salt-and-vinegar')
  end

  it "resets all the pins after triggering" do
    expect(@arduino).to receive(:digital_write).once

    (1..13).each do |n|
      expect(@arduino).to receive(:digital_write) do |num, truthy|
        expect(num).to eq(n)
        expect(truthy).to eq(false)
      end
    end

    VendingMachine.instance.dispense('salt-and-vinegar')
  end

end
