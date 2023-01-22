require 'serialport'

module RFIDPadSerial
  DEFAULT_BAUD = 57600
  DEFAULT_BITS = 8
  DEFAULT_PARITY = SerialPort::NONE # :odd :even
  DEFAULT_STOP_BITS = 1
  
  attr_accessor :options
    
  def initialize_serial(serial_path, opts={}, &read_block)
    @port = nil
    @serial_path = serial_path
    @read_block = read_block

    self.options = {
      baud: DEFAULT_BAUD,
      bits: DEFAULT_BITS,
      stop: DEFAULT_STOP_BITS,
      parity: DEFAULT_PARITY,
    }.merge(opts)

  end
  
  def open
    @port = SerialPort.new(@serial_path, options[:baud], options[:bits], options[:stop], options[:parity]).tap do |p|
      p.read_timeout = 200
    end
        
    @read_thread = Thread.new do
      @parser.reset!
      loop do
        @read_block.call(@port.read(32))
      end
    end
  end
  
  def close
    @read_thread&.kill
    @port.close unless @port.nil? || @port.closed?
    @port = nil
  end
end