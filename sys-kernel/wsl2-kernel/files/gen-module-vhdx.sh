#!/bin/bash
KVER="${1}"
KIMG="${2}"
gen_modules_vhdx.sh /lib/modules/${KVER} ${KVER} /boot/modules-${KVER}.vhdx
cp ${KIMG} /mnt/c/wsl-kernel
cp /boot/modules-${KVER}.vhdx /mnt/c/modules.vhdx
