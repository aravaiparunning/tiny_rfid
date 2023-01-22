#!/usr/bin/env ruby

$:.unshift('lib')
require "rfid_pad"

pad = RFIDPad.new("/dev/tty.SLAB_USBtoUART")
pad.open
pad.get_serial_number{|serial_number| puts "Reader Serial Number: #{serial_number.data.inspect}"}
pad.inventory do |tag|
  puts "tag: #{tag.bib_number}"
end

pad.close