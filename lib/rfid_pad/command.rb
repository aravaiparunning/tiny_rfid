require 'bytes'

module RFIDPadCommand
  INVENTORY =	0x01
  READ_DATA =	0x02
  WRITE_DATA =	0x03
  WRITE_EPC =	0x04
  KILL_TAG =	0x05
  LOCK = 0x06
  BLOCK_ERASE = 0x07
  SET_PRIVACY_WITH_MASK =	0x08
  SET_PRIVACY_WITHOUT_MASK =	0x09
  RESET_PRIVACY =	0x0a
  CHECK_PRIVACY =	0x0b
  EAS_CONFIGURE =	0x0c
  EAS_ALARM =	0x0d
  SINGLE_TAG_INVENTORY =	0x0f
  BLOCK_WRITE =	0x10
  READ_MONZA4_QT =	0x11
  SET_MONZA4_QT =	0x12
  EXTENSION_READ =	0x15
  EXTENSION_WRITE =	0x16
  BUFFER_INVENTORY =	0x18
  
  GET_READER_INFORMATION = 0x21
  SET_REGION = 0x22
  
  SET_ADDRESS =	0x24
  SET_INVENTORY_SCAN_TIME =	0x25
  SET_BAUD_RATE =	0x28
  SET_RF_POWER =	0x2f
  SET_GPIO =	0x46
  GET_GPIO_STATUS =	0x47
  GET_SERIAL_NUMBER =	0x4c
  SET_TAG_CUSTOM_FUNC =	0x3a
  BEEP_SETTING =	0x40
  SET_BUFFER_EPC_LEN =	0x70
  GET_BUFFER_EPC_LEN =	0x71
  GET_BUFFER_DATA =	0x72
  CLEAR_BUFFER =	0x73
  GET_TAG_NUMBER = 	0x74
  
  def compose_request(cmd, data=[], reader_addr: 0)
    # 05 00 4c dt cl cb
    # ^len to follow (includes CRC bytes, not the length byte)
    #    ^ reader addr (default zer)
    #       ^ cmd
    #          ^ data
    #             ^ CRC16
    
    len = data.length + 1 + 1 + 2 # +reader_addr +cmd +crc_low +crc_high
    str = [len, reader_addr, cmd]
    str += thing_as_bytes(data)
    crc = CRC16.new
    crc << str
    str << crc.value
    
    str.pack("CC#{len-2}v")
  end
end
