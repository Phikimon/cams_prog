#!/bin/bash

prompt()
{
	echo
	echo -n "Press any key to continue"
	stty raw
	REPLY=$(dd bs=1 count=1 2> /dev/null)
	stty -raw
	echo
	echo
}

# Check arguments

if [ "$1" == "-h" ]
then
	echo "Usage: $0 <config_file>"
	echo ""
	echo "Config file format(name cameras.config):"
	echo "	segment_duration_min = 10"
	echo "	days_for_segment_to_live = 10"
	echo "	camera_1_address = login:pass@127.0.0.1:554"
	echo "	..."
	echo "	camera_10_address = login10:pass10@127.0.0.10:554"
	exit
fi

CONF_FILE="$1"

test -e "$CONF_FILE"
if [ $? -ne 0 ]
then
	echo "File '$CONF_FILE' nonexistent"
	exit
fi

# Load default values
segment_duration_min=10
days_for_segment_to_live=60

# Parse config files
echo "Parsing config file:"
CONF_FILE_CONTENT=$(cat "$CONF_FILE" | sed 's/ = /=/')
eval "$CONF_FILE_CONTENT"

for i in $(seq 1 $(wc -l $CONF_FILE | awk '{print $1}'))
do
	ADDRESS_VAR_NAME="camera_"$i"_address"
	if [ -z ${!ADDRESS_VAR_NAME} ]
	then
		CAM_NUM=$(($i-1))
		echo "$CAM_NUM cameras initialized."
		break
	fi
done

if [ $CAM_NUM -eq '0' ]
then
	exit
fi

test -e "$cloud_dir"
if [ $? -ne 0 ]
then
	echo "Directory '$cloud_dir' nonexistent"
	exit
fi

# Print parsed config
echo "	cloud_dir                = $cloud_dir"
echo "	temp_dir                 = $temp_dir"
echo "	segment_duration_min     = $segment_duration_min"
echo "	days_for_segment_to_live = $days_for_segment_to_live"
for i in $(seq $CAM_NUM)
do
	ADDRESS_VAR_NAME="camera_"$i"_address"
	echo "	camera_${i}_address         = ${!ADDRESS_VAR_NAME}"
	mkdir -p "$cloud_dir/camera_$i"
	mkdir -p "$temp_dir/camera_$i"
done

prompt

#Start recording

while :
do
	for i in $(seq $CAM_NUM)
	do
		ADDRESS_VAR_NAME="camera_"$i"_address"
		echo "`date +\"[%D %H:%M:%S]\"` Cam #$i(${!ADDRESS_VAR_NAME}): Start recording"
		screen -d -m \
			-S record ffmpeg \
			-rtsp_transport tcp \
			-i rtsp:/${!ADDRESS_VAR_NAME}/ch01.264?ptype=tcp \
			-acodec copy \
			-f segment \
			-segment_time $segment_duration_min \
			-segment_format avi \
			-reset_timestamps 1 \
			-copyts \
			-flags global_header \
			-strftime 1 \
			\"$temp_dir/camera_$i/record_`date +\"%y-%m-%d_%H-%M-%S.mkv\"`\"
	done

	SLEEP_TIME=$(($segment_duration_min * 90))
	echo "`date +\"[%D %H:%M:%S]\"` Sleep for $SLEEP_TIME"
	sleep $SLEEP_TIME

	for i in $(seq $CAM_NUM)
	do
		find "$cloud_dir/camera_$i" -mtime +$days_for_segment_to_live -exec rm -- '{}' \;
		find "$temp_dir/camera_$i" -mmin +$segment_duration_min -exec mv -- '{}' $cloud_dir \;
	done
done
