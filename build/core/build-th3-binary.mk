
LOCAL_BUILD_SCRIPT := BUILD_THRID_PARTY_EXEC
LOCAL_MAKEFILE     := $(local-makefile)

$(call check-defined-LOCAL_MODULE,$(LOCAL_BUILD_SCRIPT))
$(call check-LOCAL_MODULE,$(LOCAL_MAKEFILE))
$(call check-LOCAL_MODULE_FILENAME)

$(call assert-defined, LOCAL_TARGET_TOP )

$(if $(strip $(wildcard $(LOCAL_TARGET_TOP))),,\
	$(call __ndk_info,$(LOCAL_MAKEFILE):$(LOCAL_MODULE): ERROR:Veriable LOCAL_TARGET_TOP `$(LOCAL_TARGET_TOP)` to point an invalid path.)\
$(call __ndk_error,Aborting ...) \
)

# we are building target objects
my := TARGET_


ifndef LOCAL_TARGET_CMD
LOCAL_TARGET_CMD :=$(strip cd $(LOCAL_TARGET_TOP))
else
PRIVATE_th3_temp_prep_cmd_func = \
$(if $(filter %;,$(lastword $(strip $1))),\
$(call PRIVATE_th3_temp_prep_cmd_func,$(call chop,$1) $(subst ;,,$(lastword $(strip $1))))\
,$(strip $1))

#Keep the source of raw command line,don't process '; 'character.
#The command line can be properly by Makefle grammar.
LOCAL_TARGET_CMD :=cd $(LOCAL_TARGET_TOP) && $(LOCAL_TARGET_CMD)
#LOCAL_TARGET_CMD := $(call PRIVATE_th3_temp_prep_cmd_func,$(LOCAL_TARGET_CMD))
#LOCAL_TARGET_CMD :=$(strip $(subst ;, && ,$(LOCAL_TARGET_CMD)))
endif

LOCAL_TARGET_COPY_FILES :=$(foreach a,$(LOCAL_TARGET_COPY_FILES),$(patsubst %/,%,$(LOCAL_TARGET_TOP))/$(a))

$(call handle-module-filename,,)
$(call handle-module-built)

LOCAL_MODULE_CLASS := THRID_PARTY_EXEC
include $(BUILD_SYSTEM)/build-module.mk
