require 'rubygems'
require 'ffi'

module Pinmame
  class Rectangle < FFI::Struct
    layout  :min_x, :int,
            :max_x, :int,
            :min_y, :int,
            :max_y, :int
  end
end