LOCAL_PATH := $(call my-dir)

ifndef TARGET_RELEASE_DIR
$(warning "Need TARGET_RELEASE_DIR, Otherwise, use default")
TARGET_RELEASE_DIR := ${LOCAL_PATH}
endif

ifndef TARGET_WORKSPACE
TARGET_WORKSPACE := ${LOCAL_PATH}
endif

ifndef TARGET_LSP_DIR
TARGET_LSP_DIR := ${TARGET_WORKSPACE}/packages/linux_lsp
endif

IMG_RELEASEDIR := $(TARGET_RELEASE_DIR)/boards/${TARGET_PLATFORM}/${TARGET_BOARD}
export IMG_RELEASEDIR

ROOTFS_OUT     := $(TARGET_WORKSPACE)/rootfs


$(info -------------------------------------------)
$(info TARGET_WORKSPACE   = $(TARGET_WORKSPACE))
$(info TARGET_SDK_DIR     = $(TARGET_SDK_DIR))
$(info TARGET_LSP_DIR     = $(TARGET_LSP_DIR))
$(info TARGET_RELEASE_DIR = $(TARGET_RELEASE_DIR))
$(info -------------------------------------------)

HOST_TOOL := ${TARGET_LSP_DIR}/ostools
CPU_BIT_WIDTH := $(shell uname -m)
ifeq (${CPU_BIT_WIDTH}, "x86_64")
DEFAULTMAKEDEVS := ${HOST_TOOL}/bin/makedevs-64
DEFAULTMKUBIFS  := ${HOST_TOOL}/bin/mkfs.ubifs-64
DEFAULTUBINIZE  := ${HOST_TOOL}/bin/ubinize-64
else
DEFAULTMAKEDEVS := ${HOST_TOOL}/bin/makedevs-32
DEFAULTMKUBIFS  := ${HOST_TOOL}/bin/mkfs.ubifs-32
DEFAULTUBINIZE  := ${HOST_TOOL}/bin/ubinize-32
endif

TOOLS_DIR=/opt/linux1.2/tools

Q = @

# Compile each modules
#first build SDK module
$(call include-makefiles, $(TARGET_SDK_DIR)/make.mk)
$(call include-all-subs-makefile, $(TARGET_WORKSPACE)/packages)

# Prepare for compiling, it should be called as: sys-build prepare_env
#prepare_env:
#	$(Q)echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) IOS start"
#	$(Q)rm -rf $(ROOTFS_OUT)/*
#	$(Q)tar xf $(TARGET_LSP_DIR)/rootfs/nfs/hi3520d/rootfs.tar.gz -C $(TARGET_WORKSPACE)
#	$(Q)mv -v $(TARGET_WORKSPACE)/rootfs_hi35xx $(ROOTFS_OUT)/
#	$(Q)rm -rf $(TARGET_WORKSPACE)/rootfs_hi35xx

# End for compiling, it should be called as: sys-build finish_env
makeos:
	$(Q)cd ${ROOTFS_OUT} && sudo find . | cpio -H newc -o > ${IMG_RELEASEDIR}/initramfs.img
	$(Q)gzip -9 ${IMG_RELEASEDIR}/initramfs.img
	$(Q)mv ${IMG_RELEASEDIR}/initramfs.img.gz ${IMG_RELEASEDIR}/initramfs.img
	$(Q)mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d ${IMG_RELEASEDIR}/initramfs.img ${IMG_RELEASEDIR}/uInitramfs
	$(Q)rm ${IMG_RELEASEDIR}/initramfs.img && chmod 777 ${IMG_RELEASEDIR}/uInitramfs

	#build master image
	$(Q)cp -f ${IMG_RELEASEDIR}/master/uImage ${IMG_RELEASEDIR}/linux.ios
	$(Q)cd ${IMG_RELEASEDIR} && ${TOOLS_DIR}/updata linux.ios uInitramfs update.linux
	$(Q)mv ${IMG_RELEASEDIR}/update.linux ${IMG_RELEASEDIR}/master/update.linux
	$(Q)chmod 777 ${IMG_RELEASEDIR}/master/update.linux
	
	#build single image
	$(Q)rm -f ${IMG_RELEASEDIR}/linux.ios
	$(Q)cp -f ${IMG_RELEASEDIR}/uImage ${IMG_RELEASEDIR}/linux.ios
	$(Q)cd ${IMG_RELEASEDIR} && ${TOOLS_DIR}/updata linux.ios uInitramfs update.linux
	$(Q)chmod 777 ${IMG_RELEASEDIR}/update.linux
	mv ${IMG_RELEASEDIR}/update.linux ${IMG_RELEASEDIR}/update.linux.single

	$(Q)tar cvzf ${IMG_RELEASEDIR}/rootfs.tar.bz2 $(ROOTFS_OUT)
	
	#build slave image
	$(Q)rm -f ${IMG_RELEASEDIR}/linux.ios
	$(Q)cp -f ${IMG_RELEASEDIR}/slave/uImage ${IMG_RELEASEDIR}/linux.ios
	$(Q)rm -f ${ROOTFS_OUT}/bin/netcbb_daemon
	$(Q)rm -f ${ROOTFS_OUT}/bin/pppd
	$(Q)rm -f ${ROOTFS_OUT}/bin/pppoe
	$(Q)rm -f ${ROOTFS_OUT}/sbin/dropbear
	$(Q)rm -f ${ROOTFS_OUT}/sbin/dropbearkey
	$(Q)cd ${ROOTFS_OUT} && sudo find . | cpio -H newc -o > ${IMG_RELEASEDIR}/initramfs.img
	$(Q)gzip -9 ${IMG_RELEASEDIR}/initramfs.img
	$(Q)mv ${IMG_RELEASEDIR}/initramfs.img.gz ${IMG_RELEASEDIR}/initramfs.img
	$(Q)mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d ${IMG_RELEASEDIR}/initramfs.img ${IMG_RELEASEDIR}/uInitramfs
	$(Q)rm ${IMG_RELEASEDIR}/initramfs.img && chmod 777 ${IMG_RELEASEDIR}/uInitramfs
	$(Q)cd ${IMG_RELEASEDIR} && ${TOOLS_DIR}/updata linux.ios uInitramfs update.linux
	$(Q)mv ${IMG_RELEASEDIR}/update.linux ${IMG_RELEASEDIR}/slave/update.linux
	$(Q)chmod 777 ${IMG_RELEASEDIR}/slave/update.linux
	
	$(Q)rm -f ${IMG_RELEASEDIR}/linux.ios
	
	mv ${IMG_RELEASEDIR}/update.linux.single ${IMG_RELEASEDIR}/update.linux
	$(Q)rm -rf $(ROOTFS_OUT)
	$(Q)echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) IOS finished"
	
