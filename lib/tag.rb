class Tag
  attr_reader :epc
  
  def initialize(epc:, rssi: nil)
    @epc = epc
    @rssi = rssi
  end
  
  
  def bib_number
    return nil if @epc.nil?

    # [172, 35, 73, 7, 16, 0, 0, 0, 0, 0, 3, 32] => 320
    # Strip leading zeros, but treat as a string.
    zi = 0
    (6..@epc.length).each do |i|
      if @epc[i] != 0
        zi = i
        break
      end
    end

    @epc[zi..-1].map{|x| x.to_s(16)}.join
  end
end