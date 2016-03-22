LOCAL_PATH := $(call my-dir)

ifneq (,$(findstring _v7,$(TARGET_ALIAS_BOARD)))
IPC_PLAT := ipcv7
endif

ifneq (,$(findstring _v5,$(TARGET_ALIAS_BOARD)))
IPC_PLAT := ipcv5
endif

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

# 这是安霸的SDK需要使用的一些工具，它们是从原厂SDK包里面取出来，提交至服务器上的
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
PACKAGES_PATH  :=  $(TARGET_WORKSPACE)/packages

$(call include-makefile, $(TARGET_SDK_DIR)/make.mk)

ifeq ($(wildcard $(TARGET_LSP_DIR)/rootfs), $(TARGET_LSP_DIR)/rootfs)
$(call include-all-subs-makefile,$(TARGET_LSP_DIR)/rootfs)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/802dot1x), $(PACKAGES_PATH)/802dot1x)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/802dot1x)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/ddns), $(PACKAGES_PATH)/ddns)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/ddns)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/alglibs), $(PACKAGES_PATH)/alglibs)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/alglibs)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/mediactrl), $(PACKAGES_PATH)/mediactrl)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/mediactrl)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/sysdbg), $(PACKAGES_PATH)/sysdbg)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/sysdbg)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/drvlib), $(PACKAGES_PATH)/drvlib)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/drvlib)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/kdbox), $(PACKAGES_PATH)/kdbox)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/kdbox)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/ftpc), $(PACKAGES_PATH)/ftpc)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/ftpc)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/netcbbs), $(PACKAGES_PATH)/netcbbs)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/netcbbs)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/smoothsend), $(PACKAGES_PATH)/smoothsend)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/smoothsend)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/udm), $(PACKAGES_PATH)/udm)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/udm)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/upnp), $(PACKAGES_PATH)/upnp)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/upnp)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/sac), $(PACKAGES_PATH)/sac)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/sac)
endif

ifeq ($(wildcard $(PACKAGES_PATH)/mbm), $(PACKAGES_PATH)/mbm)
$(call include-all-subs-makefile,$(PACKAGES_PATH)/mbm)
endif

ifeq ($(IPC_PLAT),ipcv7)
ifeq ($(wildcard $(PACKAGES_PATH)/ispctrl/make.mk), $(PACKAGES_PATH)/ispctrl/make.mk)
$(call include-makefile,$(PACKAGES_PATH)/ispctrl/make.mk)
endif
endif

# 在正式开始编译前，应该先执行此目标，在安霸平台下面，主要是准备好一个rootfs框架
# 后面编译内核或者SDK等模块时生成的bin文件，驱动模块，动态库文件可能需要打包在rootfs里面
# 如果某些平台在正式编译前没有明确要求准备的环境，也可以不用定义此目标
# Prepare for compiling, it should be called as: sys-build prepare_env
#prepare_env:
#	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) start"
#	$(Q) rm -rf $(ROOTFS_OUT)/
#	$(Q) tar xf $(TARGET_LSP_DIR)/rootfs/nfs/$(TARGET_PLATFORM)/rootfs.tar.bz2 -C $(TARGET_WORKSPACE)
#	$(Q) if [ -d $(TARGET_LSP_DIR)/rootfs/boards/$(TARGET_BOARD) ]; then \
#		cp -af $(TARGET_LSP_DIR)/rootfs/boards/$(TARGET_BOARD)/* $(ROOTFS_OUT); \
#	     fi

# 在正式编译结束后，应该执行此目标，在安霸平台下面，主要是生成rootfs的镜像，并发布到发布路径下
# 如果某些平台在正式编译后没有明确要求善后工作，也可以不用定义此目标
# End for compiling, it should be called as: sys-build finish_env
#finish_env:
.PHONY: makeos $(TARGET_BOARD) $(TARGET_ALIAS_BOARD)

hdc_s2_v5: $(TARGET_BOARD)
hdc_s2_v7: $(TARGET_BOARD)
hdc_s266_v5: $(TARGET_BOARD)
hdc_s266_v7: $(TARGET_BOARD)
ipc_185_v5: $(TARGET_BOARD)
ipc_185_v7: $(TARGET_BOARD)
ipc_s2_v5: $(TARGET_BOARD)
ipc_s2_v7: $(TARGET_BOARD)
ipc_s255_v5: $(TARGET_BOARD)
ipc_s255_v7: $(TARGET_BOARD)
ipc_s266_v5: $(TARGET_BOARD)
ipc_s266_v7: $(TARGET_BOARD)
makeos: $(TARGET_ALIAS_BOARD)
$(TARGET_BOARD):
	$(Q) if [ -d $(TARGET_SDK_DIR)/boards/$(TARGET_BOARD)/bin ]; then \
		cp -af $(TARGET_SDK_DIR)/boards/$(TARGET_BOARD)/bin/* \
		$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD); \
		fi
	$(Q) export LINUX_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		export ELF_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		. $(TARGET_SDK_DIR)/build/env/Linaro-multilib-gcc4.8.env; \
		$(MAKE) build_fsimage -s -C $(TARGET_SDK_DIR)/boards/$(TARGET_BOARD)
	$(Q) cp -af $(TARGET_SDK_DIR)/out/$(TARGET_BOARD)/rootfs/rootfs.cpio.gz \
		$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)/rootfs.img
#	$(Q) rm -rf $(ROOTFS_OUT)
	$(Q) export LINUX_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		export ELF_TOOLCHAIN_PREFIX=$(shell dirname $(APP_ARM_TOOLCHAIN))/../..; \
		. $(TARGET_SDK_DIR)/build/env/Linaro-multilib-gcc4.8.env; \
		$(MAKE) build_fw -s -C $(TARGET_SDK_DIR)/boards/$(TARGET_BOARD) \
		RELEASEDIR=$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD);
	$(Q) mkdir -p $(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)/update_pkg; \
		cp -af $(TARGET_SDK_DIR)/out/$(TARGET_BOARD)/amboot/memfwprog/*.bin \
		$(TARGET_RELEASE_DIR)/boards/$(TARGET_PLATFORM)/$(TARGET_BOARD)/update_pkg
	$(Q) echo "Compile $(TARGET_PLATFORM)-$(TARGET_BOARD) finished"

