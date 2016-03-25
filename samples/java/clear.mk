
java-local-vars := JAVA_LIBRARIES \
	               JAVA_JAR \
				   JAVA_INCLUDES  


# 清除所有自定义Java变量
java-clear-vars = $(foreach var,$(call java-local-vars),\
	              $(eval LOCAL_$(var) := $(empty)))
				  
# 清除所有java自定义变量 
$(call java-clear-vars)

#清除sys-build 所有变量
include $(CLEAR_VARS)
