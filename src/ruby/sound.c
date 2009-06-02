//============================================================
//
//	sound.c - Win32 implementation of MAME sound routines
//
//============================================================

// MAME headers
#include "driver.h"
#include "osdepend.h"
#include "window.h"
#include "video.h"
#include "rc.h"

//============================================================
//	osd_start_audio_stream
//============================================================

int osd_start_audio_stream(int stereo)
{
	return 0;
}


//============================================================
//	osd_stop_audio_stream
//============================================================

void osd_stop_audio_stream(void)
{
}


//============================================================
//	osd_update_audio_stream
//============================================================

int osd_update_audio_stream(INT16 *buffer)
{
	return 0;
}


//============================================================
//	osd_set_mastervolume
//============================================================

void osd_set_mastervolume(int _attenuation)
{
}



//============================================================
//	osd_get_mastervolume
//============================================================

int osd_get_mastervolume(void)
{
	return 0;
}



//============================================================
//	osd_sound_enable
//============================================================

void osd_sound_enable(int enable_it)
{
}
