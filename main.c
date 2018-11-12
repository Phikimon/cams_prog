#include "camera.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>

enum {MAX_CAM_NUM = 16};

int main(void)
{
	int cam_num;
	int i;
	char c;
	char log_file_name[MAX_STR_LEN] = {0};
	int log_file, config_file;

	/* Get number of cams */
	printf("Enter number of cams: ");
	scanf("%d", &cam_num);
	assert(cam_num > 0);
	assert(cam_num <= MAX_CAM_NUM);

	/* Open log file */
	printf("Use default log address?(default: /tmp/camera.log) (y/n): ");
	c = getchar();
	if (c == 'y')
	{
		printf("Enter log file name: ");
		assert(MAX_STR_LEN == 128);
		scanf("%127s", log_file_name);
	} else
	{
		strcpy(log_file_name, "/tmp/camera.log");
	}
	log_file = open(log_file_name, O_APPEND);
	assert(log_file > 0);

	/* Open config file */
	printf("Use default config file(default: /tmp/camera.config) (y/n): ");
	c = getchar();
	if (c == 'y')
	{
		printf("Enter config file name: ");
		assert(MAX_STR_LEN == 128);
		scanf("%127s", config_file_name);
	} else
	{
		strcpy(config_file_name, "/tmp/camera.config");
	}
	config_file = open(log_file_name, O_APPEND);
	assert(config_file > 0);

	/* Read cameras' configs */
	struct camera cams[MAX_CAM_NUM] = {0};
	for (i = 0; i < cam_num; i++)
		camera_ctor(&cams[i], config_file);

	main_record_cycle(cams);
	all_cams_destroyer(cams);

	fsync(log_file);
	fclose(log_file);
	return 0;
}
