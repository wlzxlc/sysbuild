LOCAL_PATH := $(call my-dir)

# 工程顶层目录
ifndef TARGET_WORKSPACE
TARGET_WORKSPACE := ${LOCAL_PATH}
endif

ifndef TARGET_LSP_DIR
TARGET_LSP_DIR := ${TARGET_WORKSPACE}/packages/linux_lsp
endif

# 编译输出的发布路径，详解《版本发布说明》
ifndef TARGET_RELEASE_DIR
$(warning "Need TARGET_RELEASE_DIR, Otherwise, use default")
TARGET_RELEASE_DIR := ${LOCAL_PATH}
endif

IMG_RELEASEDIR := $(TARGET_RELEASE_DIR)/boards/${TARGET_PLATFORM}/${TARGET_BOARD}
export IMG_RELEASEDIR

ROOTFS_OUT     := $(TARGET_WORKSPACE)/rootfs
IOS_DIR			:= $(TARGET_WORKSPACE)/ios
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

Q = @

# 此处会搜需指定位置的make.mk文件，并将它们包含进来
# 关于函数的用法请参考sys-build的相关文档
# Compile each modules
#$(call include-all-subs-makefile, $(TARGET_WORKSPACE)/packages)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/linux_lsp/kernel/linux-3.10.28/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/mediactrl/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/drvlib/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/netcbbs/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/ddns/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/ftpc/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/smoothsend/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/upnp/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/802dot1x/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/sysdbg/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/udm/make.mk)
$(call include-makefiles, $(TARGET_WORKSPACE)/packages/ispctrl/make.mk)

makeos:
	$(Q)cd $(TARGET_WORKSPACE)
	$(Q)mkdir -p ios/rootfs
	$(Q)cp -rf $(TARGET_LSP_DIR)/rootfs/boards/baytrail/$(TARGET_BOARD)/rootfs/* $(IOS_DIR)/rootfs/
	$(Q)mkdir -p $(IOS_DIR)/rootfs/usr/bin && cp $(TARGET_RELEASE_DIR)/cbb/netcbb/exe/linux_x86/release/netcbb_daemon $(IOS_DIR)/rootfs/usr/bin/
	$(Q)cp $(TARGET_RELEASE_DIR)/cbb/drvlib/exe/linux_x86/release/hwinfo $(IOS_DIR)/rootfs/usr/bin/
	$(Q)cp $(TARGET_RELEASE_DIR)/cbb/drvlib/exe/linux_x86/release/hw_test $(IOS_DIR)/rootfs/usr/bin/
	#support older update interface
	$(Q)cp $(IOS_DIR)/rootfs/bin/allupdate $(IOS_DIR)/
	$(Q)cp $(IOS_DIR)/rootfs/bin/osupdate $(IOS_DIR)/
	#
	$(Q)cp ${IMG_RELEASEDIR}/bzImage $(IOS_DIR)/
	$(Q)tar czf ${IMG_RELEASEDIR}/update.linux ios/
	$(Q)rm -rf ios
	##make release.img.gz
	$(Q)cd $(TARGET_WORKSPACE)
	$(Q)rm -rf $(ROOTFS_OUT)/*
	$(Q)cp $(TARGET_LSP_DIR)/rootfs/nfs/x86/baytraili-release.img.bz2 ./
	$(Q)bunzip2 -fk baytraili-release.img.bz2
	$(Q)echo "123456" | sudo -S kpartx -av baytraili-release.img
	$(Q)echo  "123456" | sudo -S mount /dev/mapper/loop0p2 $(ROOTFS_OUT)/
	$(Q)echo  "123456"  | sudo -S cp $(TARGET_LSP_DIR)/kernel/linux-3.10.28/include/configs/${TARGET_BOARD}/init-boot.sh $(ROOTFS_OUT)/init
	$(Q)echo  "123456"   | sudo -S cp $(TARGET_RELEASE_DIR)/cbb/drvlib/exe/linux_x86/release/hwinfo $(ROOTFS_OUT)/usr/bin/
	$(Q)echo  "123456"  | sudo -S cp $(TARGET_RELEASE_DIR)/cbb/drvlib/exe/linux_x86/release/hw_test $(ROOTFS_OUT)/usr/bin/
	$(Q)echo  "123456"  | sudo -S cp $(TARGET_LSP_DIR)/kernel/linux-3.10.28/include/configs/${TARGET_BOARD}/telnet.sh $(ROOTFS_OUT)/usr/bin/
	$(Q)sync
	$(Q)sleep 2
	$(Q)echo  "123456"  | sudo -S umount $(ROOTFS_OUT)/
	$(Q)echo  "123456"   | sudo -S mount /dev/mapper/loop0p1 $(ROOTFS_OUT)/
	$(Q)echo  "123456"   |  sudo -S cp ${IMG_RELEASEDIR}/bzImage $(ROOTFS_OUT)/
	$(Q)sync
	$(Q)sleep 2
	$(Q)echo  "123456"   |  sudo -S umount $(ROOTFS_OUT)/
	$(Q)echo  "123456"   | sudo -S kpartx -d baytraili-release.img
	$(Q)rm baytraili-release.img.bz2
	$(Q)bzip2 baytraili-release.img 
	$(Q)mv baytraili-release.img.bz2 ${IMG_RELEASEDIR}/
	
	$(Q)echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) IOS finished"
	
