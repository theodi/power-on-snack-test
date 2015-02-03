require 'arduino_firmata'
require 'yaml'

class VendingMachine

  def self.dispense(flavour)
    arduino.digital_write(get_port(flavour), true)
    sleep 2
    reset_ports
  end

  def self.get_port(flavour)
    flavours[flavour][rand(flavours[flavour].count)]
  end

  def self.arduino
    ArduinoFirmata.connect("/dev/ttyUSB1", bps: 115200, :nonblock_io => true)
  end

  def self.flavours
    YAML.load File.read 'config/flavours.yaml'
  end

  def self.reset_ports
    (1..13).each do |n|
      arduino.digital_write(n, false)
    end
  end

end
