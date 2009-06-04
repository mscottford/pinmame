require 'rubygems'
require 'ffi'

module Pinmame
  extend FFI::Library
  
  ffi_lib 'pinmame', 'libpinmame'
  
  attach_function :osd_get_path_count, [:int], :int
end

puts Pinmame::osd_get_path_count(1)
