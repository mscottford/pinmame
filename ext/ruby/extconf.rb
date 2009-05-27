require 'mkmf'

$objs = %w[../src/ruby/fileio.o pinmame.o]
$srcs = %w[../src/ruby/fileio.c pinmame.c]

create_makefile("pinmame")

