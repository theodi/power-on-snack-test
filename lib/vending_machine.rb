require 'arduino_firmata'
require 'yaml'

class VendingMachine

  CONFIG = YAML.load File.open 'config/config.yaml'

  def self.dispense(flavour)
    port = get_port flavour
    arduino.digital_write port, true
    sleep CONFIG['pin_time']
    reset_port port
  end

  def self.get_port(flavour)
    flavours[flavour][rand(flavours[flavour].count)]
  end

  def self.arduino
    ArduinoFirmata.connect("/dev/ttyUSB#{CONFIG['usb_port']}", bps: 115200, nonblock_io: true)
  end

  def self.flavours
    YAML.load File.read 'config/flavours.yaml'
  end

  def self.reset_port port
    arduino.digital_write port, false
  end

  def self.reset_ports
    (1..13).each do |n|
      self.reset_port n
    end
  end

end
