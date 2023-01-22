# Read serial number response
# 09 00 4c 00 21 21 10 10  b5 ac
# ^len
#    ^ reader addr (default zero)
#       ^ reCmd?
#          ^ status
#             ^ serial number is "21211010"
#                         ^ CRC16 (lsb, msb)
#
# Minimum viable parser, might be worth abstracting this to 
# accept struct definitions as they're used all over the spec
#
#
class StateMachine
  
  STATES = [
    :reset, # Read the length byte
    :reader_addr,
    :cmd, #command to which this is a response
    :status,
    :data,
    :crc
  ]
  
  class Response
    attr_reader :length, :addr, :cmd, :status, :data
    
    def initialize(length: len)
      @crc = CRC16.new
      @received_length = 0
      @received_crc = 0
      @data = []
      self.length = length
    end
    
    def length=(new_length)
      @length = new_length
      @crc << new_length
    end
    
    def reader_addr=(new_addr)
      @addr = new_addr
      @crc << new_addr
      did_read(1)
    end
    
    def cmd=(new_cmd)
      @cmd = new_cmd
      @crc << new_cmd
      did_read(1)
    end
    
    def status=(new_status)
      @status = new_status
      @crc << new_status
      did_read(1)
    end
    
    def append_data(bytes)
      bytes = thing_as_bytes(bytes)
      @crc << bytes
      @data += bytes
      did_read bytes.length
    end
    
    def crc=(b)
      if remaining_length == 2
        self.crc_low = b
      else
        self.crc_high = b
      end
    end
    
    def crc_high=(b)
      @received_crc = (@received_crc & 0x00ff) | (b << 8)
      did_read 1
    end

    def crc_low=(b)
      @received_crc = (@received_crc & 0xff00) | (b << 0)
      did_read 1
    end
    
    def did_read(count)
      @received_length += count
      # puts "Did read #{count}; remaining length: #{remaining_length}".colorize(:light_black)
    end
    
    def remaining_length
      self.length - @received_length
    end
    
    def valid?
      if @received_crc != @crc.value
        puts "#{'Invalid CRC:'.colorize(:red)} #{'%04x' % @received_crc} <=> #{'%04x' % @crc.value}"
      end
      @received_crc == @crc.value
    end
  end
  
  
  def initialize(&emit_block)
    @emit_block = emit_block
    reset!
  end
  
  def reset!
    unless @response.nil?
      @emit_block.call(@response)
    end
    @state = 0
  end
  
  def << bytes
    return if bytes.nil?
    
    thing_as_bytes(bytes).each do |b|
      # puts "SM: #{("%02x" % b).colorize(:blue)} (state: #{STATES[@state]})"
      
      case STATES[@state]
      when :reset
        # This is a length byte
        @response = Response.new(length: b)
        @state += 1

      when :reader_addr
        @response.reader_addr = b
        @state += 1

      when :cmd
        @response.cmd = b
        @state += 1

      when :status
        @response.status = b
        if @response.remaining_length == 2 # no data to read
          @state += 2
        else
          @state += 1
        end

      when :data
        # Read response.remaining_length bytes and then flip to CRC the thing.
        @response.append_data(b)

        if @response.remaining_length == 2
          @state += 1
        end

      when :crc
        @response.crc = b
        reset! if @response.remaining_length == 0
      end
    end
  end
end