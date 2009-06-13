require 'rubygems'
require 'ffi'

module Pinmame
  class RegionInfo < FFI::Struct
    layout  :base, :pointer,
            :length, :size_t,
            :type, :uint32,
            :flags, :uint32
  end
end
