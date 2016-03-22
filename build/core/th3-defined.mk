
modules-LOCALS += \
	TARGET_TOP \
        TARGET_CONFIG \
        TARGET_RULER \
        TARGET_CMD \
        TARGET_TOOLCHAIN \
        TARGET_COPY_FILES \
        DEPS_MODULES \
        KERNEL_BINARY_OUTPUT_DIR \
        BOOTLOADER_OUTPUT_DIR \
        RELEASE_PATH \
        LINK_MODE \
        INSTALLED_RELEASE \
        RELATE_MODE
       



$(call module-class-register,THRID_PARTY_EXEC,,)
$(call module-class-register,KERNEL_BINARY,,)
$(call module-class-register,BOOTLOADER,,)
$(call module-class-register-installable,TEST,,)

define cmd_sys_build_help_info
@echo "Usage: sys-build [command] ..."
@echo "Commands:"
@echo "  modules          Display the current can to compile all modules"
@echo "  help             Display sys-build help information."
@echo "  clean            Remove all the temporary files and modules, for *.[od]."
@echo "  config           Configure sys-build project,it will create Applicaton.mk"
@echo "                   file in the current directory."
@echo "  tag-<TAG>        Compile all types are <TAG> all of the modules, the "
@echo "                   specific <TAG> Please refer to the following."
@echo "  clean-<module>   Remove specific module's temporary files and module."
@echo "  make-<module>-<ruler [args]>"
@echo "                   The command only to support BUILD_KERNEL and BUILD_BOOTLADER "
@echo "                   mode.It allows you to specify the module main makefile "
@echo "                   passing a command"
@echo "  shell-<module>-<cmd>"
@echo "                   The command only to support BUILD_TH3_BINARY mode.It allows you"
@echo "                   to specify the module shell script passing a command."
@echo "                   "
endef        

default-relate-mode =$(sort board plat arch compiler)

init-relate-path = \
$(foreach mode,$(default-relate-mode),\
$(if $(filter board,$(mode)),\
$(eval __ndk_app_$(mode)_relate_obj_path := $(NDK_APP_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM)/$(TARGET_BOARD))\
$(eval __ndk_app_$(mode)_relate_libs_path := $(NDK_APP_LIBS_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM)/$(TARGET_BOARD)))\
$(if $(filter plat,$(mode)),\
$(eval __ndk_app_$(mode)_relate_obj_path := $(NDK_APP_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM))\
$(eval __ndk_app_$(mode)_relate_libs_path := $(NDK_APP_LIBS_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)/$(TARGET_PLATFORM)))\
$(if $(filter arch,$(mode)),\
$(eval __ndk_app_$(mode)_relate_obj_path := $(NDK_APP_OUT)/$(TARGET_ARCH)/$(TARGET_ABI))\
$(eval __ndk_app_$(mode)_relate_libs_path := $(NDK_APP_LIBS_OUT)/$(TARGET_ARCH)/$(TARGET_ABI)))\
$(if $(filter compiler,$(mode)),\
$(eval __ndk_app_$(mode)_relate_obj_path := $(if $(strip $(TOOLCHAIN_NAME)),\
$(strip $(patsubst %-,%,$(NDK_APP_OUT)/$(TOOLCHAIN_NAME))),$(NDK_APP_OUT)/$(HOST_ARCH)))\
$(eval __ndk_app_$(mode)_relate_libs_path := $(if $(strip $(TOOLCHAIN_NAME)),\
$(strip $(patsubst %-,%,$(NDK_APP_LIBS_OUT)/$(TOOLCHAIN_NAME))),$(NDK_APP_LIBS_OUT)/$(HOST_ARCH))))\
)

# -----------------------------------------------------------------------------
#Function     :get-relate-path
#Arguments    : 1:relate_mode $(default-relate-mode)
#Arguments    : 2:path type either obj or libs
#Return       : the mode path for obj or libs
#note         : Before call init-relate-path function used.
# -----------------------------------------------------------------------------
get-relate-path = $(__ndk_app_$(1)_relate_$(2)_path) 
relate-mode-checks = \
$(if $(filter 1,$(words $(strip $1))),\
  $(if $(filter $1,$(default-relate-mode)),,\
     $(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE):ERROR Veriable LOCAL_RELATE_MODE \
        only support mode '$(default-relate-mode)' not '$1')\
     $(call __ndk_error,Abort ...))\
 ,$(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE):ERROR Veriable LOCAL_RELATE_MODE must be defiend as a word.)\
  $(call __ndk_error,Abort ...))

# -----------------------------------------------------------------------------
# Function  : get-all-archs
# Parameters:
# Returns   : Return a list of all support archs
# Usage     : $(call get-all-archs)
# Rationale : 
# -----------------------------------------------------------------------------
get-all-archs = $(NDK_ALL_ARCHS)

# -----------------------------------------------------------------------------
# Function  : get-all-platforms
# Parameters: $1:which arch.
# Returns   : Return a list of all support platform for $1.
# Usage     : $(call get-all-platforms,arm)
# Rationale : 
# -----------------------------------------------------------------------------
get-all-platforms = $(NDK_ALL_$(1)_PLATFORMS)
# -----------------------------------------------------------------------------
# Function  : get-all-boards
# Parameters: $1:which arch.
# Parameters: $2:which platform.
# Returns   : Return a list of all support board for $1 and $2.
# Usage     : $(call get-all-boards,arm,a5s)
# Rationale : 
# -----------------------------------------------------------------------------
get-all-boards = $(NDK_ALL_$(1)_$(2)_BOARDS)

# -----------------------------------------------------------------------------
# Function  : get-all-abis
# Parameters: $1:which arch.
# Returns   : Return a list of all support abi for $1.
# Usage     : $(call get-all-abis,arm)
# Rationale : 
# -----------------------------------------------------------------------------
get-all-abis = $(filter $1%,$(NDK_ALL_ABIS))

#------------------------------------------------------------------------------
#Function     : include-makefile
#Arguments    : 1:The Makefile path
#Returns      : null
#Usage        : $(call include-makefile,< your make.mk path>)
#-----------------------------------------------------------------------------
LOCAL_MY_LOCAL_PATH_STACK :=

include-makefile = \
$(if $(filter 1,$(words $1)),,$(call __ndk_info,ERROR:Too much argument list.)$(call __ndk_error,Abort ...)) \
$(if $(filter $(abspath $1),$(foreach a,$(filter %Android.mk %make.mk,$(MAKEFILE_LIST)),$(abspath $(a)))), \
$(eval $(call ndk_log,File `$(abspath $1)` already include.Skip it.)), \
$(eval LOCAL_MY_LOCAL_PATH_STACK += $(LOCAL_PATH)) \
$(eval $(call ndk_log ,Include $(abspath $1))) \
$(eval include $1) \
$(eval LOCAL_PATH :=$(strip $(lastword $(LOCAL_MY_LOCAL_PATH_STACK)))) \
$(eval LOCAL_MY_LOCAL_PATH_STACK := $(filter-out $(LOCAL_PATH),$(LOCAL_MY_LOCAL_PATH_STACK))))

#------------------------------------------------------------------------------
#Function     : include-makefiles
#Arguments    : 1:a list of the make.mk files
#Usage        : $(call include-makefiles,list)
#-----------------------------------------------------------------------------
include-makefiles = \
$(foreach make,$1,$(eval $(call include-makefile,$(make))))

#------------------------------------------------------------------------------
#Function     : include-all-subs-makefile
#Arguments    : 1:The Makefile path
#Arguments    : 2: default make.mk without $2
#Usage        : $(call include-all-subs-makefile,path1 path2 )
#-----------------------------------------------------------------------------
include-all-subs-makefile = \
$(foreach path1,$(1), \
$(if $(wildcard $(path1)),,$(info "$(call this-makefile):ERROR:Invalid path '$(path1)'.") $(error "Abort ..."))\
$(foreach inc_make,$(shell find $(path1) -name $(if $(strip $2),$2,make.mk)),$(eval $(call include-makefile,$(inc_make)))))



# -----------------------------------------------------------------------------
# Function : get-all-wildcard-files
# Arguments: 1: wildcard  paths 
# Arguments: 2: wildcard  suffix
# Returns  : return all wildcard files
# Usage    : $(call get-all-wildcard-files,../ ../../ ,.c .cpp .cxx)
# -----------------------------------------------------------------------------
get-all-wildcard-files = $(foreach path,$(patsubst %/,%,$(1)),$(foreach dsuffix,$(2),\
        $(addprefix $(path)/,$(notdir $(wildcard $(LOCAL_PATH)/$(path)/*$(dsuffix))))))



add-target-module = \
$(eval	__ndk_app_$(1)_targets_module += $2)

get-target-module-list = $(__ndk_app_$(1)_targets_module)


# -----------------------------------------------------------------------------
# Function : add-module-clean 
# Arguments: 1: valid module name 
# Arguments: 2: depends target name
# Returns  : 
# Usage    : $(call add-module-clean,Your module name,my-clean)
# -----------------------------------------------------------------------------
add-module-clean = \
	$(if $(filter 1,$(strip $(words $1))),\
	$(if $(filter clean-$1,$2),$(call __ndk_info,ERROR: Illegal target name `$2`) $(call __ndk_error,Abort ...), \
    $(call add-target-module,$1,$2)  $(eval clean-$(strip $1)::$2)),\
	$(if $(strip $1), \
	$(call __ndk_info,ERROE: The first parameter must be a word in the function add-module-clean.)\
		$(call __ndk_error,Abort ...),$(call add-target-module,__ndk_app_default,$2)$(eval clean: $2)))

get-default-fake-modules = __ndk_app_fake_generate_dir \
	                       __ndk_app_default

# -----------------------------------------------------------------------------
# Function : add-build-options
# Arguments: 1: compile args 
# Arguments: 2: host path
# Returns  : 
# Usage    : $(call add-build-options,--sysroot,/sysroot)
# -----------------------------------------------------------------------------
add-build-options = $(if $(wildcard $2),$(addprefix $1=,$(strip $(call host-path,$2))),)

