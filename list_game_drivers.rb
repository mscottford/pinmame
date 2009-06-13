require 'rubygems'
require 'ffi'

module Pinmame
  extend FFI::Library
  ffi_lib 'pinmame', 'libpinmame'
  
  MAX_GFX_ELEMENTS = 32
  MAX_MEMORY_REGIONS = 32

  class Rectangle < FFI::Struct
    layout  :min_x, :int,
            :max_x, :int,
            :min_y, :int,
            :max_y, :int
  end
  
  class RegionInfo < FFI::Struct
    layout  :base, :pointer,
            :length, :size_t,
            :type, :uint32,
            :flags, :uint32
  end
  
  class RunningMachine < FFI::Struct    
    layout  :gamedrv, :pointer, # GameDriver
            :drv, :pointer, # InternalMachineDriver
            :memory_region, [RegionInfo, MAX_MEMORY_REGIONS],
            :gfx, [:pointer, MAX_GFX_ELEMENTS], # GfxElement
            :scrbitmap, :pointer, # mame_bitmap
            :visible_area, Rectangle,
            :absolute_visible_area, Rectangle,
            :pens, :pointer, # pen_t
            :game_colortable, :pointer, # UINT16
            :remapped_colortable, :pointer, # pen_t
            :color_depth, :int,
            :orientation, :int,
            :sample_rate, :int,
            :samples, :pointer, # GameSamples
            :input_ports, :pointer, # InputPort
            :input_ports_default, :pointer, # InputPort
            :uifont, :pointer, # GfxElement
            :uifontwidth, :int,
            :uifontheight, :int,
            :uixmin, :int,
            :uiymin, :int,
            :uiwidth, :int,
            :uiheight, :int,
            :ui_orientation, :int,
            :debug_bitmap, :pointer, # mame_bitmap
            :debug_pens, :pointer, # pen_t
            :debug_remapped_colortable, :pointer, # pen_t
            :debugger_font, :pointer # GfxElement
  end
  
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
  
  attach_variable :machine, 'Machine', :pointer
  
  attach_variable :drivers, :pointer
  
  attach_function :driver_names, [], :pointer
  attach_function :driver_count, [], :int
  attach_function :driver_at_index, [:int], :pointer 
end

count = Pinmame::driver_count
count.times do |index|
  driver_pointer = Pinmame::driver_at_index index
  driver = Pinmame::GameDriver.new driver_pointer
  puts driver[:name]
end
