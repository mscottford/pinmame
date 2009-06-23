require 'rubygems'
require 'ffi'

require File.dirname(__FILE__) + '/lib/pinmame.rb'

count = Pinmame::driver_count
count.times do |index|
  driver_pointer = Pinmame::driver_at_index index
  driver = Pinmame::GameDriver.new driver_pointer
  puts driver[:name]
end
