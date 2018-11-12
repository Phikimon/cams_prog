#include <stdlib.h>
#include <assert.h>

#include "camera.h"

void camera_ctor(struct camera* cam, int config_file)
{
	/* Expected file format:
	 * # <cam_num>: delay
	 * 1:
	dscanf("%[^ ]");
	cam->delay
	return res;
}

void camera_dtor(struct camera* cam)
{
	free(cam);
}
