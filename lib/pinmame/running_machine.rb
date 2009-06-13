require 'rubygems'
require 'ffi'

module Pinmame
  MAX_GFX_ELEMENTS = 32
  MAX_MEMORY_REGIONS = 32
  
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
end