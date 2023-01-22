require 'bytes'

# Example usage:
#
# q = CRC16.new
# q << [0x09, 0x00, 0x4c, 0x00, 0x21, 0x21, 0x10, 0x10]
# puts "%04x" % q.value

class CRC16
  PRESET_VALUE = 0xffff
  POLYNOMIAL = 0x8408

  attr_reader :value

  def initialize
    @value = PRESET_VALUE
  end
  
  def <<(bytes)
    thing_as_bytes(bytes).each do |b|
      @value ^= b
      (0..7).each do |j|
        if @value & 1 == 1
          @value = (@value >> 1) ^ POLYNOMIAL
        else
          @value = (@value >> 1)
        end
      end
    end
  end
end

#
# Example reference C code from a time and place where uint8_t does not exist
#
# unsigned int uiCrc16Cal(unsigned char const  * pucY, unsigned char len)
# {
# 	unsigned char ucI,ucJ;
# 	unsigned short int  uiCrcValue = PRESET_VALUE;
# 
#    	for(ucI = 0; ucI < len; ucI++)
# 	   {
# 		   uiCrcValue = uiCrcValue ^ *(pucY + ucI);
# 	  	   for(ucJ = 0; ucJ < 8; ucJ++)
# 	   	  {
# 		 	if(uiCrcValue & 0x0001)
# 		   	{
# 		    	uiCrcValue = (uiCrcValue >> 1) ^ POLYNOMIAL;
# 		   	}
# 		 	else
# 		   	{
# 		    	uiCrcValue = (uiCrcValue >> 1);
# 		   	}
# 		}
#  	}
#   return uiCrcValue;
# }

