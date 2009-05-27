#include "ruby.h"

// wrappers for methods in fileio.c
#include "fileio.h"
static VALUE rb_create_path(VALUE self, VALUE path, VALUE has_filename)
{
	
}

static VALUE pinmame;
static VALUE fileio;

void Init_pinmame() {
	pinmame = rb_define_module("PinMame");
	fileio = rb_define_class_under(pinmame, "FileIO", rb_cObject);
	rb_define_method(fileio, "create_path", rb_create_path, 2);
}