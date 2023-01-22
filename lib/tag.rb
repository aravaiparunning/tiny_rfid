class Tag
  attr_reader :epc
  
  def initialize(epc:, rssi: nil)
    @epc = epc
    @rssi = rssi
  end
  
  def prefix
    @epc[0..6]
  end
  
  def bib_number
    return nil if @epc.nil?

    # ac2349071000000000000305
    # Strip leading zeros, but treat as a string.
    zi = 0
    epc = epc_string
    
    (12..epc.length).each do |i|
      if epc[i] != '0'
        zi = i
        break
      end
    end

    epc[zi..-1]
  end
  
  def epc_string
    @epc.map{|x| '%02x' % x}.join
  end
  
  def prefix_string
    prefix.map{|x| '%02x' % x}.join
  end
end