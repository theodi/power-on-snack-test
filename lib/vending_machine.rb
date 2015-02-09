require 'arduino_firmata'
require 'yaml'
require 'singleton'

class VendingMachine
  include Singleton

  CONFIG = YAML.load File.open 'config/config.yaml'

  def arduino
    @arduino ||= ArduinoFirmata.connect("/dev/ttyUSB#{CONFIG['usb_port']}", bps: 115200, nonblock_io: true)
  end

  def dispense(flavour)
    port = get_port flavour
    arduino.digital_write port, true
    sleep CONFIG['pin_time']
    reset_ports
    "Dispensed on chute #{port}"
  end

  def get_port(flavour)
    num = rand(VendingMachine.flavours[flavour].count)
    VendingMachine.flavours[flavour][num]
  end

  def reset_port port
    arduino.digital_write port, false
  end

  def reset_ports
    (1..13).each do |n|
      reset_port n
      sleep 0.1
    end
  end

  def self.flavours
    YAML.load File.read 'config/flavours.yaml'
  end

end
