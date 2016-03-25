
LOCAL_SRC_FILES := $(strip $(LOCAL_SRC_FILES))
#########################################################################
 java_src_files :=
 java_deps_jars :=
 java_all_prep_class := 
 java_target_name :=
 java_sourcepath :=
 javac_cmd := javac
 jar_cmd := jar
 
########################################################################
LOCAL_SRC_FILES := $(abspath $(addprefix $(LOCAL_PATH)/,$(LOCAL_SRC_FILES)))
java_src_files := $(filter %.java, $(wildcard $(LOCAL_SRC_FILES)))
LOCAL_SRC_FILES := 
ifndef java_src_files
 $(error Invalid 'LOCAL_SRC_FILES' at the '$(call local-makefile)')
endif
# 求 java_deps_jars
java_deps_jars := $(filter %.jar ,$(wildcard $(LOCAL_JAVA_JARS)))
ifdef java_deps_jars
   java_deps_jars := -classpath $(subst $(space),:,$(java_deps_jars))
endif
# 求java_sourcepath
LOCAL_JAVA_INCLUDES := $(wildcard $(LOCAL_JAVA_INCLUDES))
ifdef LOCAL_JAVA_INCLUDES
  java_sourcepath := $(patsubst %/,%,$(LOCAL_JAVA_INCLUDES))
endif
############################################################################
# 来至于包含者
LOCAL_MODULE := $(patsubst %.jar,%,$(LOCAL_MODULE))

JAVA_JAR_DIR := $(addprefix $(TARGET_OUT)/objs/,$(LOCAL_MODULE))
LOCAL_TARGET_TOP := .
java_target_name := $(LOCAL_MODULE).jar
LOCAL_TARGET_COPY_FILES := $(JAVA_JAR_DIR)/$(java_target_name)

# 增加清除目标
$(call add-module-clean,$(LOCAL_MODULE),$(LOCAL_MODULE)_clean)
# 求 java_target_name
java_target_name := $(JAVA_JAR_DIR)/$(java_target_name)

# 依赖该目标
LOCAL_DEPS_MODULES := $(java_target_name)

######################################
java_objs_dir := $(JAVA_JAR_DIR)/src

get-all-javas := $(java_src_files)
java_objs_class_dir := $(java_objs_dir)

$(if $(java_deps_jars),$(eval $(java_deps_jars):$(java_objs_class_dir)), \
	$(eval java_deps_jars := $(java_objs_class_dir)))


java_all_class :=
java_all_org_src :=
java_all_sourcepath := 

$(foreach java, $(call get-all-javas),\
  $(eval __package_path := $(shell sed -n 's/package//p' $(java))) \
  $(eval __package_path := $(subst .,/,$(__package_path))) \
  $(eval __package_path := $(subst ;,,$(__package_path))) \
  $(eval __package_path := $(patsubst %/,%,$(subst $(space),,$(__package_path)))) \
  $(eval __class_for_java := $(__package_path)/$(notdir $(java))) \
  $(eval java_all_org_src += $(__class_for_java)) \
  $(eval java_all_sourcepath += $(patsubst %/$(__class_for_java),%,$(java)))\
 )
 
java_all_org_src := $(sort $(java_all_org_src))
java_all_class += $(java_all_org_src:%.java=%.class)
java_all_class_path := $(addprefix $(java_objs_class_dir)/,$(java_all_class))

target-java-files = $(filter %/$(patsubst $(java_objs_class_dir)/%,%, \
	$(basename $1).java),$(call get-all-javas))

java_sourcepath += $(java_all_sourcepath)

java_sourcepath := $(sort $(java_sourcepath))

ifdef java_sourcepath
	java_sourcepath := $(patsubst %:,%,$(subst $(space),:,$(java_sourcepath)))
	java_sourcepath := $(patsubst :%,%,$(java_sourcepath))
    java_sourcepath := -sourcepath $(java_sourcepath)
endif

# src/org/xxx/test.class --> /home/user/java/src/org/xxx/test.java
$(foreach class, $(java_all_class_path), \
	$(eval $(class): priv_objs_src_dir := $(java_objs_class_dir)) \
	$(eval $(class): priv_source_path := $(java_sourcepath)) \
	$(eval $(class): priv_javac := $(javac_cmd)) \
	$(eval $(class): priv_module := $(notdir $(java_target_name))) \
	$(eval $(class): priv_jar_files := $(java_deps_jars)) \
	$(eval $(class): $(call target-java-files, $(class))) \
	$(eval $(call ndk_log $(class) -> $(call target-java-files, $(class)))) \
	$(eval $(class): ;\
	@echo "Build Java  : $$(priv_module) <= $$(notdir $$<)" ;\
	$$(priv_javac) $$(priv_source_path) $$(priv_jar_files) -d $$(priv_objs_src_dir) $$<))

$(java_objs_class_dir):
	@mkdir -p $@

# $(java_objs_class_dir)/$(java_all_class)
$(java_target_name): priv_obj_src_dir := $(java_objs_class_dir)
$(java_target_name): $(java_objs_class_dir) $(java_all_class_path)
$(java_target_name):
	@echo "BUILD_JAR  : $(notdir $@)"	
	@$(jar_cmd) -cf $@ -C $(priv_obj_src_dir) .

$(LOCAL_MODULE)_clean: priv_objs_src_dir := $(java_objs_class_dir)
$(LOCAL_MODULE)_clean: priv_target_name := $(java_target_name)
$(LOCAL_MODULE)_clean: 
	@rm -rf $(priv_objs_src_dir) $(priv_target_name)

include $(BUILD_TH3_BINARY)

