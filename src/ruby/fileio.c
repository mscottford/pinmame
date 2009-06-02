//============================================================
//
//	fileio.c - Cross platform file io functions
//
//============================================================

// MAME headers
#include "driver.h"
#include "unzip.h"
#include "rc.h"

//============================================================
//	TYPE DEFINITIONS
//============================================================

struct pathdata
{
	const char *rawpath;
	const char **path;
	int pathcount;
};

#define FILE_BUFFER_SIZE	256

struct _osd_file
{
	// TODO set this to the os file type
	UINT8*		handle;
	UINT64		filepos;
	UINT64		end;
	UINT64		offset;
	UINT64		bufferbase;
	UINT32		bufferbytes;
	UINT8		buffer[FILE_BUFFER_SIZE];
};

//============================================================
//	osd_get_path_count
//============================================================

int osd_get_path_count(int pathtype)
{
	return 0;
}



//============================================================
//	osd_get_path_info
//============================================================

int osd_get_path_info(int pathtype, int pathindex, const char *filename)
{
	return 0;
}



//============================================================
//	osd_fopen
//============================================================

// TODO: Replace with cross platform version
// This method is currently borken
osd_file *osd_fopen(int pathtype, int pathindex, const char *filename, const char *mode)
{
	return NULL;
}


//============================================================
//	osd_fseek
//============================================================

int osd_fseek(osd_file *file, INT64 offset, int whence)
{
	return 0;
}



//============================================================
//	osd_ftell
//============================================================

UINT64 osd_ftell(osd_file *file)
{
	return file->offset;
}



//============================================================
//	osd_feof
//============================================================

int osd_feof(osd_file *file)
{
	return (file->offset >= file->end);
}



//============================================================
//	osd_fread
//============================================================

// TODO: Replace with cross platform version
// This method is currently borken
UINT32 osd_fread(osd_file *file, void *buffer, UINT32 length)
{
	return 0;
}



//============================================================
//	osd_fwrite
//============================================================

// TODO: Replace with cross platform version
// This method is currently borken
UINT32 osd_fwrite(osd_file *file, const void *buffer, UINT32 length)
{
	return 0;
}



//============================================================
//	osd_fclose
//============================================================

// TODO: Replace with cross platform version
// This method is currently borken
void osd_fclose(osd_file *file)
{
}



//============================================================
//	osd_display_loading_rom_message
//============================================================

// called while loading ROMs. It is called a last time with name == 0 to signal
// that the ROM loading process is finished.
// return non-zero to abort loading
int osd_display_loading_rom_message(const char *name,struct rom_load_data *romdata)
{
	return 0;
}
