
//============================================================
//
//	input.c - Win32 implementation of MAME input routines
//
//============================================================

// MAME headers
#include "driver.h"
#include "window.h"
#include "rc.h"
#include "input.h"


//============================================================
//	osd_get_key_list
//============================================================

const struct KeyboardInfo *osd_get_key_list(void)
{
	return NULL;
}

//============================================================
//	osd_is_key_pressed
//============================================================

int osd_is_key_pressed(int keycode)
{
	return 0;
}

//============================================================
//	osd_readkey_unicode
//============================================================

int osd_readkey_unicode(int flush)
{
	return 0;
}

//============================================================
//	osd_get_joy_list
//============================================================

const struct JoystickInfo *osd_get_joy_list(void)
{
	return NULL;
}

//============================================================
//	osd_is_joy_pressed
//============================================================

int osd_is_joy_pressed(int joycode)
{
	return 0;
}

//============================================================
//	osd_analogjoy_read
//============================================================

void osd_analogjoy_read(int player, int analog_axis[], InputCode analogjoy_input[])
{
}


int osd_is_joystick_axis_code(int joycode)
{
	return 0;
}


//============================================================
//	osd_lightgun_read
//============================================================

void osd_lightgun_read(int player,int *deltax,int *deltay)
{
}

//============================================================
//	osd_trak_read
//============================================================

void osd_trak_read(int player, int *deltax, int *deltay)
{
}



//============================================================
//	osd_joystick_needs_calibration
//============================================================

int osd_joystick_needs_calibration(void)
{
	return 0;
}



//============================================================
//	osd_joystick_start_calibration
//============================================================

void osd_joystick_start_calibration(void)
{
}



//============================================================
//	osd_joystick_calibrate_next
//============================================================

const char *osd_joystick_calibrate_next(void)
{
	return 0;
}



//============================================================
//	osd_joystick_calibrate
//============================================================

void osd_joystick_calibrate(void)
{
}



//============================================================
//	osd_joystick_end_calibration
//============================================================

void osd_joystick_end_calibration(void)
{
}



//============================================================
//	osd_customize_inputport_defaults
//============================================================

void osd_customize_inputport_defaults(struct ipd *defaults)
{
}


//============================================================
//	osd_get_leds
//============================================================

int osd_get_leds(void)
{
	return 0;
}



//============================================================
//	osd_set_leds
//============================================================

void osd_set_leds(int state)
{
}
