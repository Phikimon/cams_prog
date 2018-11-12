#ifndef CAMERA_H
#define CAMERA_H

enum {MAX_STR_LEN = 128};

struct camera
{
	int video_fragment_duration;
	int copy_period;
	char camera_ip[MAX_STR_LEN];
	char rec_address[MAX_STR_LEN];
	char c_rec_address[MAX_STR_LEN];
};

struct camera* camera_ctor(void);
void           camera_dtor(struct camera* cam);

#endif
