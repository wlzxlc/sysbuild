LOCAL_PATH := $(call my-dir)

# 判断目标厂商是否存在，因为在安霸的平台下面，SDK路径是有厂商名称的
# 而厂商名在各个平台的配置文件里不一定都有定义，所以安霸的平台下面一定要作此判断
# 否则会出现找不到SDK错误
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

# 这是安霸的SDK需要使用的一些工具，从原厂SDK包里面取出来，提交至服务器上的
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

Q = @

# 此处会搜需指定位置的make.mk文件，并将它们包含进来
# 关于函数的用法请参考sys-build的相关文档
# Compile each modules
$(call include-all-subs-makefile, $(TARGET_LSP_DIR)/rootfs)
$(call include-makefile, $(TARGET_SDK_DIR)/make.mk)
$(call include-makefiles, $(call all-makefiles-under, $(TARGET_WORKSPACE)/packages))

# 在正式开始编译前，应该先执行此目标，在安霸平台下面，主要是准备好一个rootfs框架
# 后面编译内核/SDK等模块时生成的bin文件，驱动模块，动态库文件可能需要打包在rootfs里面
# 如果某些平台在正式编译前没有明确要求准备的环境，也可以不用定义此目标
# Prepare for compiling, it should be called as: sys-build prepare_env
#prepare_env:
#	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) start"
#	$(Q) rm -rf $(TARGET_WORKSPACE)/_fakeroot.cpio $(ROOTFS_OUT)
#	$(Q) tar xf $(TARGET_LSP_DIR)/rootfs/nfs/$(TARGET_PLATFORM)/rootfs.tar.bz2 -C $(TARGET_WORKSPACE)
#	$(Q) if [ -d $(TARGET_LSP_DIR)/rootfs/boards/$(TARGET_BOARD) ]; then \
#		cp -af $(TARGET_LSP_DIR)/rootfs/boards/$(TARGET_BOARD)/* $(ROOTFS_OUT); \
#	     fi

# 在正式编译结束后，应该执行此目标，在安霸平台下面，主要是生产rootfs的镜像，并发布到发布路径下
# 如果某些平台在正式编译后没有明确要求善后工作，也可以不用定义此目标
# End for compiling, it should be called as: sys-build finish_env
#finish_env:
makeos:
	$(Q) find ${TARGET_WORKSPACE}/rootfs/bin -type f -executable | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	$(Q) find ${TARGET_WORKSPACE}/rootfs/lib -type f -name *.so | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	$(Q) find ${TARGET_WORKSPACE}/rootfs/lib -type f -name *.so.[0-9]* | xargs ${APP_ARM_TOOLCHAIN}strip --strip-unneeded
	$(Q) echo "chown -R 0:0 $(TARGET_WORKSPACE)/rootfs" > $(TARGET_WORKSPACE)/_fakeroot.cpio
	$(Q) echo "${DEFAULTMAKEDEVS} -d ${HOST_TOOL}/config/device_table.txt $(TARGET_WORKSPACE)/rootfs" >> _fakeroot.cpio
	$(Q) echo "cd $(TARGET_WORKSPACE)/rootfs && find . | cpio --quiet -o -H newc > ${TARGET_WORKSPACE}/rootfs.cpio" >> _fakeroot.cpio
	$(Q) chmod +x $(TARGET_WORKSPACE)/_fakeroot.cpio
	$(Q) fakeroot -- $(TARGET_WORKSPACE)/_fakeroot.cpio
	$(Q) gzip -9 $(TARGET_WORKSPACE)/rootfs.cpio && mv $(TARGET_WORKSPACE)/rootfs.cpio.gz $(TARGET_WORKSPACE)/ramfs.img
	$(Q) rm -rf $(TARGET_WORKSPACE)/_fakeroot.cpio ${ROOTFS_OUT}
	$(Q) mv $(TARGET_WORKSPACE)/ramfs.img $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)
	$(Q) export LINUX_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		export ELF_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		. $(TARGET_SDK_DIR)/build/env/CodeSourcery.env; \
		$(MAKE) fw -s -C $(TARGET_SDK_DIR) \
		RELEASEDIR=$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD);
	$(Q) mkdir -p $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)/update_pkg;\
		cp -af $(TARGET_SDK_DIR)/amboot/build/memfwprog/*.bin \
		$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)/update_pkg
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"

