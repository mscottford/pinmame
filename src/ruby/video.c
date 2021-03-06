//============================================================
//
//	video.c - Win32 video handling
//
//============================================================

// standard C headers
#include <math.h>

// MAME headers
#include "driver.h"
#include "mamedbg.h"
#include "vidhrdw/vector.h"
#include "video.h"
#include "window.h"
#include "rc.h"

//============================================================
//	osd_create_display
//============================================================

int osd_create_display(const struct osd_create_params *params, UINT32 *rgb_components)
{
	return 0;
}

//============================================================
//	osd_close_display
//============================================================

void osd_close_display(void)
{
}



//============================================================
//	osd_skip_this_frame
//============================================================

int osd_skip_this_frame(void)
{
	return 0;
}



//============================================================
//	osd_get_fps_text
//============================================================

const char *osd_get_fps_text(const struct performance_info *performance)
{
	return NULL;
}

//============================================================
//	osd_update_video_and_audio
//============================================================

void osd_update_video_and_audio(struct mame_display *display)
{
}



//============================================================
//	osd_override_snapshot
//============================================================

struct mame_bitmap *osd_override_snapshot(struct mame_bitmap *bitmap, struct rectangle *bounds)
{
	return NULL;
}



//============================================================
//	osd_pause
//============================================================

void osd_pause(int paused)
{
}
