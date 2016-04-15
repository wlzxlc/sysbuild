GNUMAKE := make
include $(dir $(lastword $(MAKEFILE_LIST)))/build/core/build-local.mk
