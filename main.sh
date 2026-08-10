#!/bin/bash

# Backup Location

# - Drive
# -- Fedora

declare -A devices_hash # Connected removable lsblk devices and their description pairs.
devices=() # Indexed and filtered block devices.

BACKUP_FROM=("$HOME/Pictures" "$HOME/Documents" "$HOME/Projects" "$HOME/Music")
MOUNT_POINT=""

BACKUP_DRIVE=""
CURRENT_DATE=$(date +%F)

ROOT_FOLDER_NAME="Fedora_backup_test"

getConnectedDevices() {
    while read -r line; do
        eval "$line"

        [[ "$RM" == "0" ]] && continue
        [[ -z "$MOUNTPOINTS" ]] && continue

        devices_hash["/dev/$NAME"]="/dev/$NAME ($SIZE) (mounted at \"$MOUNTPOINTS\")"
    done < <(lsblk -P -o NAME,SIZE,MOUNTPOINTS,RM)
}

indexAndOutputDevices() {
	i=0
	for device in "${!devices_hash[@]}"; do
	    devices[i]="$device"
	    echo "$i) ${devices_hash[$device]}"
	    ((i++))
	done
}

setMountpointAndDrive() {
	MOUNT_POINT=$(lsblk -no MOUNTPOINTS "${devices[$drive_selection]}")
	BACKUP_DRIVE="${devices[$drive_selection]}"

	[[ "$BACKUP_DRIVE" == "" ]] && exit 0

}

copyAndCompress() {
	printf -v backup_locations '%s, ' "${BACKUP_FROM[@]}"

	echo "Drive selected: $BACKUP_DRIVE"
	echo "Backing up from ${backup_locations%,}. Okay? (y/N)"

	read ok
	[[ "${ok^^}" != "Y" ]] && echo "Quitting." && exit 0;

	# User has selected to continue
	# Tar up the selected locations

	for location in "${BACKUP_FROM[@]}"; do
		
		IFS='/' read -a array <<< "$location"

		mkdir -p "$MOUNT_POINT/$ROOT_FOLDER_NAME/${array[-1]}/"
		tar -cJvf "$MOUNT_POINT/$ROOT_FOLDER_NAME/${array[-1]}/$CURRENT_DATE.tar.xz" \
			--exclude="*.rpp-bak" \
			--exclude="*.reapeaks" \
			--exclude="SURGE XT" \
			"$location"

	done

}

getConnectedDevices

#If no suitable devices, exit
[[ ${#devices_hash[@]} == 0 ]] && echo "Connect backup medium (No medium to backup to!)." && exit 1;

clear -x #Clear view but do not delete history

echo "AUTO-BACKUP TOOL"
echo "Select a device..."

indexAndOutputDevices
echo "---"

read drive_selection

setMountpointAndDrive
copyAndCompress