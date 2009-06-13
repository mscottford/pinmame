require 'rubygems'
require 'ffi'

module Pinmame
  extend FFI::Library
  
  callback :drv_callback, [:pointer], :void
  callback :driver_init_callback, [], :void

  class GameDriver < FFI::Struct
    layout  :source_file, :string,
            :clone_of, :pointer,
            :name, :string,
            :bios, :pointer,
            :description, :string,
            :year, :string,
            :manufactuer, :string,
            :drv, :drv_callback,
            :input_ports, :pointer,
            :driver_init, :driver_init_callback,
            :rom, :pointer,
            :flags, :uint32
  end
end