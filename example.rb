#!/usr/bin/env ruby

require 'tiny_rfid'

pad = RFIDPad.new("/dev/tty.SLAB_USBtoUART")
pad.open
pad.beep(true)
pad.get_serial_number{|serial_number| puts "Reader Serial Number: #{serial_number.data.inspect}"}
pad.inventory do |tag|
  if tag.prefix_string.start_with? 'ac23'
    puts "tag: #{tag.bib_number} #{tag.prefix_string.colorize(:light_black)}"
  else
    puts "other: #{tag.epc_string}".colorize(:light_black)
  end
end

pad.close