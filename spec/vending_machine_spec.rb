require 'spec_helper'

describe VendingMachine do

  before(:each) do
    @arduino = instance_double("ArduinoFirmata::Arduino")
    allow(ArduinoFirmata).to receive(:connect).with("/dev/ttyUSB1", bps: 115200, :nonblock_io => true)
                                              .and_return(@arduino)
  end

  it "sends a message to one of the correct pins" do
    expect(@arduino).to receive(:digital_write) do |num, truthy|
      expect(num).to be_between(1,3).inclusive
      expect(truthy).to eq(true)
    end
    expect(@arduino).to receive(:digital_write).at_least(1).times

    VendingMachine.dispense('salt-and-vinegar')
  end

  it "resets all the pins after triggering one" do
    expect(@arduino).to receive(:digital_write).once

    (1..13).each do |n|
      expect(@arduino).to receive(:digital_write) do |num, truthy|
        expect(num).to eq(n)
        expect(truthy).to eq(false)
      end
    end

    VendingMachine.dispense('salt-and-vinegar')
  end

end
