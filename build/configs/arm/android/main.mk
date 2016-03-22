# ----------------------------------------------------
# Auto genarate templements
# Author : lichao@kedacom.com
# Time   :Mon Aug 31 10:35:28 CST 2015
# ----------------------------------------------------
# Always to point an absolute path of the this make.mk
LOCAL_PATH := $(call my-dir)

# These variables by script auto genarate. In order 
# to reduce the current make writing burden. if you 
# are have any question and to see:
# $(sysbuild_root)/docs/A&Q.txt. 
# About to usage of the this make.mk, you are can 
# to see :
# $(sysbuild_root)/docs/make_mk.txt
 
 
# Include others make.mk
# $(call include-makefiles, /foo/make.mk /boo/make.mk)
.PHONY: makeos $(TARGET_ALIAS_BOARD)

$(call include-makefiles, \
 $(wildcard $(TARGET_WORKSPACE)/packages/*/make.mk))

$(TARGET_ALIAS_BOARD):
	@echo Builded $@ done.
	
makeos:$(TARGET_ALIAS_BOARD)
