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

APP_ARCH := x86
APP_ABI  := x86
APP_PLATFORM := x86
APP_BOARD := default_board

APP_X86_TOOLCHAIN :=
APP_MIPS_TOOLCHAIN := mips-linux-
APP_PPC_TOOLCHAIN := ppc-linux-
APP_ARM_TOOLCHAIN := arm-none-linux-gnueabi- 
APP_TOOLCHAIN_SYSROOT :=

APP_WORKSPACE := $(APP_PROJECT_PATH)

APP_SDK_DIR := $(APP_PROJECT_PATH)
APP_LSP_DIR := $(APP_PROJECT_PATH)
APP_RELEASE_DIR :=
