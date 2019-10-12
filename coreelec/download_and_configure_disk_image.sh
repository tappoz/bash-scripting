#!/usr/bin/env bash

VERSION=9.2.0
IMG_FILENAME=CoreELEC-Amlogic.arm-${VERSION}-Generic.img
ZIP_FILENAME=${IMG_FILENAME}.gz

IMG_1=img1
FULL_IMG_1="$(pwd)/${IMG_1}"
IMG_2=img2
FULL_IMG_2="$(pwd)/${IMG_2}"

if [ ! -f ${ZIP_FILENAME} ]; then
  echo -e "\n\nDownloading ${ZIP_FILENAME}\n\n"
  wget https://github.com/CoreELEC/CoreELEC/releases/download/${VERSION}/${ZIP_FILENAME}
else
  echo -e "\n\nNo need to download ${ZIP_FILENAME}\n\n"
fi

echo -e "\n\nUnzipping ${ZIP_FILENAME}\n\n"
# `yes n` means answering "no" (overwrite) to the interactive prompt
yes n | gunzip -k ${ZIP_FILENAME}

echo -e "\n\nCheck the image:"
# sudo apt install qemu-utils
qemu-img info ${IMG_FILENAME}

echo -e "\n\nThese are the info about the partitions on: ${IMG_FILENAME}\n\n"
FDISK_L_IMG=$(fdisk -l ${IMG_FILENAME})
echo "${FDISK_L_IMG}"

echo -e "\n\nSector size:"
SECTOR_SIZE=$(echo "${FDISK_L_IMG}" | grep "Units: sectors of" | awk '{print $8}')
echo "${SECTOR_SIZE}"

echo -e "\n\n${IMG_1} start block:"
IMG_1_START_BLOCK=$(echo "${FDISK_L_IMG}" | grep "${IMG_1}" | awk '{print $3}')
echo "${IMG_1_START_BLOCK}"

echo -e "\n\n${IMG_2} start block:"
IMG_2_START_BLOCK=$(echo "${FDISK_L_IMG}" | grep "${IMG_2}" | awk '{print $2}')
echo "${IMG_2_START_BLOCK}"

# check https://linuxconfig.org/how-to-mount-rasberry-pi-filesystem-image
mkdir -p ${FULL_IMG_1}
mkdir -p ${FULL_IMG_2}

mount ${IMG_FILENAME} -o loop,offset=$(( ${SECTOR_SIZE} * ${IMG_1_START_BLOCK})) ${FULL_IMG_1}/

echo -e "\n\nBefore moving the files..."
ls -lah ${FULL_IMG_1}/
cp ${FULL_IMG_1}/device_trees/gxl_p212_1g.dtb ${FULL_IMG_1}/
mv ${FULL_IMG_1}/gxl_p212_1g.dtb ${FULL_IMG_1}/dtb.img
echo -e "\n\nAfter moving the files..."
ls -lah ${FULL_IMG_1}/

# md5sum img1/dtb.img
# md5sum img1/device_trees/gxl_p212_1g.dtb

umount ${FULL_IMG_1}/
