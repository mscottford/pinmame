require 'rubygems'
require 'ffi'

module Pinmame
  extend FFI::Library
  ffi_lib 'pinmame', 'libpinmame'    
    
  attach_variable :machine, 'Machine', :pointer
  
  attach_variable :drivers, :pointer
  
  attach_function :driver_names, [], :pointer
  attach_function :driver_count, [], :int
  attach_function :driver_at_index, [:int], :pointer 
end
