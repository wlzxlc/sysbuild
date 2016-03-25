LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/common.mk

include $(CLEAR_JAVA_VARS)
LOCAL_MODULE := webrtc_jar
LOCAL_SRC_FILES := source/HelloWorld.java
                      	
LOCAL_JAVA_JARS := /opt/android_sdk/platforms/android-18/android.jar
include $(BUILD_JAVA_LIBRARY)

