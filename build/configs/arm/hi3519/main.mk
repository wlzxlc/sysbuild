LOCAL_PATH := $(call my-dir)

# 判断目标厂商是否存在，因为在安霸的平台下面，SDK路径是有厂商名称的
# 而厂商名在各个平台的配置文件里不一定都有定义，所以安霸的平台下面一定要作此判断
# 否则会出现找不到SDK错误
ifeq ($(TARGET_VENDOR),)
$(error "need TARGET_VENDOR")
endif

# 以下几个路径由于在联编时，会被多个模块引用，为了保证整体编译的一致性，
# 强制在sys-build config时定义，各个模块在编写make.mk的时候应该确保这些变量不要被二次覆盖，以免后面的模块访问出错
# 这些变量默认定义在各个平台在sys-build当中对应的common_config里面，特殊情况下可以直接在命令行中进行覆盖
# 此处判断这些值如果没有，联编将会直接退出

# SYSDEV工程的顶层目录
ifndef TARGET_WORKSPACE
$(error "Need TARGET_WORKSPACE to building $(TARGET_PLATFORM) project")
endif

# SDK包所在位置相对TARGET_WORKSPACE的路径
ifndef TARGET_SDK_DIR
$(error "Need TARGET_SDK_DIR to building $(TARGET_PLATFORM) project")
endif

# Linux_lsp所在位置相对TARGET_WORKSPACE的路径
ifndef TARGET_LSP_DIR
$(error "Need TARGET_LSP_DIR to building $(TARGET_PLATFORM) project")
endif

# 编译输出的发布路径，详解《版本发布说明》
ifndef TARGET_RELEASE_DIR
$(error "Need TARGET_RELEASE_DIR to building $(TARGET_PLATFORM) project")
endif

# Rootfs所在路径，一些组件可能编译完成后需要打包在rootfs当中的某个位置
# 则在自己的make.mk当中加上一句：LOCAL_RELEASE_PATH += $(ROOTFS_XXX)
# 到时sys-build就会把这个组件拷贝至rootfs中指定的目录下
ROOTFS_OUT := $(TARGET_WORKSPACE)/rootfs

TMP_RELEASE_DIR := $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)

HOST_TOOL := /opt/linux1.2/tools
Q = @
# 此处会搜需指定位置的make.mk文件，并将它们包含进来
# 关于函数的用法请参考sys-build的相关文档
# Compile each modules

#$(call include-makefiles, $(call all-makefiles-under, $(TARGET_WORKSPACE)/packages))
$(call include-all-subs-makefile, $(TARGET_WORKSPACE)/packages)

# 在正式开始编译前，应该先执行此目标，在海思平台下面，主要是准备好一个rootfs框架
# 后面编译内核或者SDK等模块时生成的bin文件，驱动模块，动态库文件可能需要打包在rootfs里面
# 如果某些平台在正式编译前没有明确要求准备的环境，也可以不用定义此目标
# Prepare for compiling, it should be called as: sys-build prepare_env
#prepare_env:
#	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) start"
#	$(Q) rm -rf $(ROOTFS_OUT)/
#	$(Q) tar xjf $(TARGET_LSP_DIR)/rootfs/nfs/$(TARGET_PLATFORM)/rootfs.tar.bz2 -C $(TARGET_WORKSPACE)


# End for compiling, it should be called as: sys-build makeos
makeos:
	$(Q) find ${TARGET_WORKSPACE}/rootfs/bin -type f -executable | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	$(Q) find ${TARGET_WORKSPACE}/rootfs/lib -type f -name *.so | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	$(Q) find ${TARGET_WORKSPACE}/rootfs/lib -type f -name *.so.[0-9]* | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	#$(Q) tar xjf $(TARGET_LSP_DIR)/rootfs/nfs/$(TARGET_PLATFORM)/rootfs.tar.bz2 -C $(TARGET_WORKSPACE)
	$(Q) mv $(TMP_RELEASE_DIR)/uImage $(TMP_RELEASE_DIR)/linux.ios
	$(Q) mv $(TMP_RELEASE_DIR)/boot/u-boot.hbl $(TMP_RELEASE_DIR)/boot/u-boot.bin
	$(Q) mv $(TMP_RELEASE_DIR)/boot/manuboot/u-boot.hbl $(TMP_RELEASE_DIR)/boot/manuboot/u-boot-manu.bin
	$(Q) cd $(ROOTFS_OUT) && find . | cpio -H newc -o > $(TMP_RELEASE_DIR)/initramfs.img
	$(Q) gzip -9 $(TMP_RELEASE_DIR)/initramfs.img && mv $(TMP_RELEASE_DIR)/initramfs.img.gz $(TMP_RELEASE_DIR)/initramfs.img
	$(Q) cd $(TMP_RELEASE_DIR) && mkimage -A arm -O linux -T ramdisk -C none -a 0x82000000 -e 0x82000000 -n cpioInitramfs -d initramfs.img uInitramfs
	$(Q) cd $(TMP_RELEASE_DIR) && rm initramfs.img && chmod 777 uInitramfs
	$(Q) cd $(TMP_RELEASE_DIR) && $(HOST_TOOL)/updata linux.ios uInitramfs update.linux
	$(Q) cd $(TMP_RELEASE_DIR) && chmod 777 update.linux
	$(Q) rm -rf $(ROOTFS_OUT)
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"	
