require 'spec_helper'

describe VendingMachine do

  before(:each) do
    @arduino = instance_double("ArduinoFirmata::Arduino")
    allow(ArduinoFirmata).to receive(:connect).with("/dev/ttyUSB1", bps: 115200, nonblock_io: true)
                                              .and_return(@arduino)
  end

  it "sends a message to one of the correct pins" do
    expect(@arduino).to receive(:digital_write) do |num, truthy|
      expect([6, 5, 7]).to include num
      expect(truthy).to eq(true)
    end
    expect(@arduino).to receive(:digital_write).at_least(1).times

    VendingMachine.dispense('salt-and-vinegar')
  end

  it "resets the pin after triggering" do
    expect(@arduino).to receive(:digital_write).once

    expect(@arduino).to receive(:digital_write) do |num, truthy|
      expect([6, 5, 7]).to include num
      expect(truthy).to eq(false)
    end
    
    VendingMachine.dispense('salt-and-vinegar')
  end

end
