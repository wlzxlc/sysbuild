LOCAL_PATH := $(call my-dir)

# 判断目标厂商是否存在
ifeq ($(TARGET_VENDOR),)
$(error "need TARGET_VENDOR")
endif

# 以下三个路径分别指向A5S工程的顶层目录/SDK的目录/LSP的目录，强制在sys-build config时定义，尽量不要二次覆盖
# 这些变量默认定义在各个平台在sys-build当中对应的common_config里面
#
# 工程顶层目录
ifndef TARGET_WORKSPACE
$(error "Need TARGET_WORKSPACE")
endif

# SDK包所在位置相对TARGET_WORKSPACE的路径
ifndef TARGET_SDK_DIR
$(error "Need TARGET_SDK_DIR")
endif

# Linux_lsp所在位置相对TARGET_WORKSPACE的路径
ifndef TARGET_LSP_DIR
$(error "Need TARGET_LSP_DIR")
endif

# 编译输出的发布路径，详解《版本发布说明》
ifndef TARGET_RELEASE_DIR
$(error "Need TARGET_RELEASE_DIR to building $(TARGET_PLATFORM) project")
endif

# 下面一组关于rootfs的变量，一些组件可能编译完成后需要打包在rootfs当中的某个位置
# 则在自己的make.mk当中加上一句：LOCAL_RELEASE_PATH += $(ROOTFS_XXX)
# 到时sys-build就会把这个组件拷贝至rootfs中指定的目录下
ROOTFS_OUT     := $(TARGET_WORKSPACE)/rootfs

# 将子make.mk在联编时可以直接引用的变量打印出来
# 各个变量在上方都有对应的说明
$(info -------------------------------------------)
$(info TARGET_WORKSPACE        = $(TARGET_WORKSPACE))
$(info TARGET_SDK_DIR          = $(TARGET_SDK_DIR))
$(info TARGET_LSP_DIR          = $(TARGET_LSP_DIR))
$(info ROOTFS_OUT              = $(ROOTFS_OUT))
$(info -------------------------------------------)

Q = @

# 此处会搜需指定位置的make.mk文件，并将它们包含进来
# 关于函数的用法请参考sys-build的相关文档
# Compile each modules
 $(call include-all-subs-makefile, $(TARGET_LSP_DIR)/rootfs)
# compile sdk
 $(call include-makefile, $(TARGET_SDK_DIR)/make.mk)
# compile kernel
 $(call include-makefile, $(TARGET_LSP_DIR)/kernel/linux-2.6.37/make.mk)
# compile u-boot
 $(call include-makefile, $(TARGET_LSP_DIR)/boot/u-boot-2010.06/make.mk)
# compile all cbb
 $(call include-makefiles, $(call all-makefiles-under, $(TARGET_WORKSPACE)/packages))

LOCAL_TMP_RELEASE := $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)
LOCAL_RELEASE_PATH := $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)

TOOLS_DIR := $(TARGET_LSP_DIR)/ostools/bin
#	$(Q) find $(TARGET_LSP_DIR)/kernel/linux-2.6.37/.modules -name *.ko | xargs -i cp -r {} $(ROOTFS_OUT)/lib/modules

# with copy u-boot.min
#makeos:
#	$(Q) cd $(ROOTFS_OUT) && find . | cpio -H newc -o > $(LOCAL_TMP_RELEASE)/initramfs.img
#	$(Q) gzip -9 $(LOCAL_TMP_RELEASE)/initramfs.img && mv $(LOCAL_TMP_RELEASE)/initramfs.img.gz $(LOCAL_TMP_RELEASE)/initramfs.img
#	$(Q) mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d $(LOCAL_TMP_RELEASE)/initramfs.img $(LOCAL_TMP_RELEASE)/ramfs.img
#	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/ramfs.img
#	$(Q) cd $(LOCAL_TMP_RELEASE) && $(TOOLS_DIR)/mksys -b u-boot.bin -k uImage -r ramfs.img -o update.linux
#	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/update.linux
#	$(Q) rm -f $(LOCAL_TMP_RELEASE)/initramfs.img
#	$(Q) tar cvzf $(LOCAL_TMP_RELEASE)/rootfs.tar.gz $(ROOTFS_OUT)
#	$(Q) rm -rf $(ROOTFS_OUT)
#	$(Q) mv $(LOCAL_RELEASE_PATH)/u-boot.min.nand $(LOCAL_RELEASE_PATH)/ubl.bin
#	$(Q) mv $(LOCAL_RELEASE_PATH)/u-boot.min.uart $(LOCAL_RELEASE_PATH)/sft.bin
#	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"

makeos:
	$(Q) cd $(ROOTFS_OUT) && find . | cpio -H newc -o > $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) gzip -9 $(LOCAL_TMP_RELEASE)/initramfs.img && mv $(LOCAL_TMP_RELEASE)/initramfs.img.gz $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d $(LOCAL_TMP_RELEASE)/initramfs.img $(LOCAL_TMP_RELEASE)/ramfs.img
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/ramfs.img
	$(Q) cd $(LOCAL_TMP_RELEASE) && $(TOOLS_DIR)/mksys -b u-boot.bin -k uImage -r ramfs.img -o update.linux
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/update.linux
	$(Q) rm -f $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) tar cvzf $(LOCAL_TMP_RELEASE)/rootfs.tar.gz $(ROOTFS_OUT)
	$(Q) rm -rf $(ROOTFS_OUT)
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"
	$(Q) cp $(TOOLS_DIR)/dm81xx_loader/* $(LOCAL_TMP_RELEASE)/manuboot

legacy_makeos:
	$(Q) cd $(ROOTFS_OUT) && find . | cpio -H newc -o > $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) gzip -9 $(LOCAL_TMP_RELEASE)/initramfs.img && mv $(LOCAL_TMP_RELEASE)/initramfs.img.gz $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d $(LOCAL_TMP_RELEASE)/initramfs.img $(LOCAL_TMP_RELEASE)/ramfs.img
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/ramfs.img
	$(Q) cp $(LOCAL_TMP_RELEASE)/ramfs.img $(LOCAL_TMP_RELEASE)/uInitramfs
	$(Q) cp $(LOCAL_TMP_RELEASE)/uImage $(LOCAL_TMP_RELEASE)/linux.ios
	$(Q) cd $(LOCAL_TMP_RELEASE) && $(TOOLS_DIR)/updata linux.ios uInitramfs update.linux
	$(Q) chmod 777 $(LOCAL_TMP_RELEASE)/update.linux
	$(Q) rm -f $(LOCAL_TMP_RELEASE)/initramfs.img
	$(Q) tar cvzf $(LOCAL_TMP_RELEASE)/rootfs.tar.gz $(ROOTFS_OUT)
	$(Q) rm -rf $(ROOTFS_OUT)
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"
	$(Q) cp $(TOOLS_DIR)/dm81xx_loader/* $(LOCAL_TMP_RELEASE)/manuboot
