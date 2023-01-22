require_relative 'rfid_pad/serial'
require_relative 'rfid_pad/command'
require_relative 'rfid_pad/state_machine'

class RFIDPad
  include RFIDPadSerial
  include RFIDPadCommand
  
  def initialize(serial_path, opts={})
    @parser = StateMachine.new do |response|
      # We got a response for some reason
      dispatch_response(response)
    end
    
    @callbacks = Hash.new do |h, cmd_id|
      h[cmd_id] = []
    end
        
    initialize_serial(serial_path, opts) do |bytes|
      @parser << bytes
    end
  end
  
  def dispatch_response(response)
    @callbacks[response.cmd].each do |cb|
      cb[:block].call(response)
      @callbacks[response.cmd].delete(cb) if cb[:one_shot] 
    end
  end
  
  def send_request(cmd, data=[], reader_addr: 0, &block)
    register_callback(cmd, reader_addr: reader_addr, one_shot: true, &block) if block_given?

    request = compose_request(cmd, data, reader_addr: reader_addr)
    # puts "Writing: #{request.unpack("C*").map{|x| '%02x' % x}.join(' ')}"
    @port.write(request)
  end
  
  def register_callback(cmd, one_shot: false, reader_addr:0, &block)
    @callbacks[cmd] << {block: block, one_shot: one_shot} if block_given?
  end

  def get_serial_number(&block)
    send_request(GET_SERIAL_NUMBER, &block)
  end
  
  def beep(flag)
    send_request(BEEP_SETTING, flag ? [1] : [0])
  end

  def inventory(&block)
    will_stop = false
    
    request_params = [
      14,    # qvalue (1-15), number of tags to read
      0,    # session,
      0x1,  # maskmem, 0x01 for EPC memory, 0x02 for TID memory and 0x03 for User memory
      0x0,  # 16-bit
      0,    # masklen,
      0,    # maskdata,
      0,    # adr in tid,
      0,    # lentid  = 0   # Optional
      0,    # target = 0    # Optional
      0x80, # ant = 0x80 (only one antenna available)       # Optional
      5,    # scantime = n * 100ms  # Optional
    ].pack("CCCzCCC")

    register_callback(RFIDPadCommand::INVENTORY) do |response|
      pause_length = 0.05
      if response.status != 1
        puts "Unexpected status #{response.status}".colorize(:red)
      else
        data = response.data
        ant = data[0]
        count = data[1]
      
        # Parse the response for tag data
        # The reference doc is pretty vague here, but it's
        # len_byte, epc[12], rssi <repeat the whole thing `count` times>
        #
        if count >= 1
          ri = 2 # already read ant & count
          while ri < data.length
            len = data[ri]; ri += 1
            epc = data[ri...ri+len]; ri += len
            rssi = data[ri]; ri+= 1
            block.call(Tag.new(epc: epc, rssi: rssi))
          end         

          pause_length = 1
        end
      end
      
      sleep(pause_length)
      send_request(RFIDPadCommand::INVENTORY, request_params)
    end

    send_request(RFIDPadCommand::INVENTORY, request_params)

    # Prevent control returning to the caller, which would
    # likely result in the program exiting.
    loop do
      sleep(1)
      break if will_stop
    end
  end
end