LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_VENDOR),)
$(error need TARGET_VENDOR))
endif

#TARGET_WORKSPACE := $(abspath $(LOCAL_PATH))
#TARGET_SDK_DIR   := $(TARGET_WORKSPACE)/sdks/$(TARGET_VENDOR)/$(TARGET_PLATFORM)
#TARGET_LSP_DIR   := $(TARGET_WORKSPACE)/packages/linux_lsp

ifndef TARGET_RELEASE_DIR
$(warning "Need TARGET_RELEASE_DIR, Otherwise, use default")
TARGET_RELEASE_DIR := $(TARGET_WORKSPACE)
endif
#LOCAL_RELEASE_PATH := $(TARGET_RELEASE_DIR)/$(TARGET_PLATFORM)/$(TARGET_BOARD)

#export TARGET_WORKSPACE
#export TARGET_SDK_DIR
#export TARGET_LSP_DIR
#export TARGET_RELEASE_DIR

$(info -------------------------------------------)
$(info TARGET_WORKSPACE   = $(TARGET_WORKSPACE))
$(info TARGET_SDK_DIR     = $(TARGET_SDK_DIR))
$(info TARGET_LSP_DIR     = $(TARGET_LSP_DIR))
$(info TARGET_RELEASE_DIR = $(TARGET_RELEASE_DIR))
$(info -------------------------------------------)

ROOTFS_OUT := $(TARGET_WORKSPACE)/rootfs

LOCAL_TMP_RELEASE := $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)

Q = @
TOOLS_DIR=/opt/linux1.2/tools

# Compile each modules
$(call include-makefile, $(TARGET_WORKSPACE)/sdks/hisilicon/hi35xx/make.mk)
$(call include-all-subs-makefile, $(TARGET_WORKSPACE)/packages/)
#$(call include-makefiles, $(call all-makefiles-under, $(TARGET_WORKSPACE)/packages))
#$(call include-all-subs-makefile, $(TARGET_WORKSPACE)/packages/netcbbs/make.mk)

# Prepare for compiling, it should be called as: sys-build prepare_env
#prepare_env:
#	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) start"
#	$(Q) rm -rf $(ROOTFS_OUT)/
#	$(Q) tar xf $(TARGET_LSP_DIR)/rootfs/nfs/hi3520d/rootfs.tar.gz -C $(TARGET_WORKSPACE)
#	$(Q) mv -v $(TARGET_WORKSPACE)/rootfs_hi35xx  $(ROOTFS_OUT)/
#	$(Q) rm -f $(TARGET_LSP_DIR)/kernel/linux-3.0.8/drivers/klsp
#	$(Q) ln -s $(TARGET_LSP_DIR)/kernel/klsp $(TARGET_LSP_DIR)/kernel/linux-3.0.8/drivers/klsp

# End for compiling, it should be called as: sys-build finish_env
makeos:
	$(Q) cd $(ROOTFS_OUT) && find . | cpio -H newc -o > $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) gzip -9 $(LOCAL_TMP_RELEASE)/initramfs.img && mv $(LOCAL_TMP_RELEASE)/initramfs.img.gz $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d $(LOCAL_TMP_RELEASE)/initramfs.img $(LOCAL_TMP_RELEASE)/uInitramfs
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/uInitramfs
	$(Q) cp $(LOCAL_TMP_RELEASE)/uImage $(LOCAL_TMP_RELEASE)/linux.ios
	$(Q) cd $(LOCAL_TMP_RELEASE) && $(TOOLS_DIR)/updata linux.ios uInitramfs update.linux
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/update.linux
	$(Q) rm -f $(LOCAL_TMP_RELEASE)/initramfs.img $(LOCAL_TMP_RELEASE)/uInitramfs $(LOCAL_TMP_RELEASE)/uImage
	$(Q) tar cvzf $(LOCAL_TMP_RELEASE)/rootfs.tar.bz2 $(ROOTFS_OUT)
	$(Q) rm -rf $(ROOTFS_OUT)
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"
