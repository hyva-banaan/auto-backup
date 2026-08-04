#!/bin/bash

declare -A devices_hash # Connected removable lsblk devices and their description pairs.
devices=() # Indexed and filtered block devices.

MOUNT_POINT=""

clear -x

echo "AUTO-BACKUP TOOL"
echo ""

getConnectedDevices() {
    while read -r line; do
        eval "$line"

        [[ "$RM" == "0" ]] && continue
        [[ -z "$MOUNTPOINTS" ]] && continue

        devices_hash["/dev/$NAME"]="/dev/$NAME ($SIZE) (mounted at \"$MOUNTPOINTS\")"
    done < <(lsblk -P -o NAME,SIZE,MOUNTPOINTS,RM)
}

outputAndIndexDevices() {
	i=0
	for device in "${!devices_hash[@]}"; do
	    devices[i]="$device"
	    echo "$i) ${devices_hash[$device]}"
	    ((i++))
	done
}

navigateToMountPoint() {
	MOUNT_POINT=$(lsblk -no MOUNTPOINTS "${devices[$drive_selection]}")
}

getConnectedDevices
echo "Select a device..."
echo ""

outputAndIndexDevices
echo "---"

read drive_selection
echo ""

navigateToMountPoint
echo "Device ${devices[$drive_selection]} successfully selected!"
echo ""
