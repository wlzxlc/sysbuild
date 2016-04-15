# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This is the default Application.mk that is being used for applications
# that don't provide $PROJECT_PATH/jni/Application.mk
#
#APP_PROJECT_PATH := $(NDK_PROJECT_PATH)

# We expect the build script to be located here
APP_BUILD_SCRIPT := $(APP_PROJECT_PATH)/make.mk
#debug
APP_OPTIM := release

APP_STL :=
APP_OUTPUT_DIR := out
#1
APP_DEBUG_MODULES :=
#1
NDK_LOG :=
APP_MODULES :=

APP_ARCH := x86_64
APP_ABI  := x86_64
APP_PLATFORM := intel
APP_BOARD := default_board_name
APP_ALIAS_BOARD := default_alias_board_name

APP_TOOLCHAIN :=
APP_TOOLCHAIN_SYSROOT := x86_64-linux-gnu-

APP_WORKSPACE := $(APP_PROJECT_PATH)

APP_SDK_DIR :=.
APP_LSP_DIR :=.
APP_RELEASE_DIR := out/release

NDK_APP_APPLICATION_CONFIG_MK = $(wildcard config.mk)
-include $(NDK_APP_APPLICATION_CONFIG_MK)
