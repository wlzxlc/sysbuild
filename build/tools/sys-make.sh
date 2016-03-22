#/bin/sh

#######################################################################
space=" "
space3=${space}${space}${space}
space4=${space3}${space}
space8=${space4}${space4}
space16=${space8}${space8}

mk_find_src_files()
{
	first_entry="1"
	target_module_extension_suffix=( $1 )
	for sufffix in ${target_module_extension_suffix[*]}
	  do
		  _files=`find . -maxdepth 1 -name  "*$sufffix"`
		 for file in $_files
		 do 
			 filter_file="test"
			 if [ "`echo $file | grep -oE $filter_file`" = $filter_file ]
			    then
				 echo "Ignore test file '$dir/$file'"
			     continue
			   fi 
			 if [ "$first_entry" == "1" ] 
			   then
			 echo "$file \\" >> .src_files
			   first_entry="0"
			  else
			 echo "${space16}${space3}$file \\" >> .src_files
			  fi

		 done
      done
	  all_src_files=`cat .src_files`
	  rm -rf .src_files >> /dev/null
}
mk_write_header()
{
cat > ${1} << EOF
# ----------------------------------------------------
# Auto genarate templements
# Author : lichao@keacom.com
# Time   :`date`
# ----------------------------------------------------
# Always to point an absolute path of the this make.mk
LOCAL_PATH := \$(call my-dir)

# These variables by script auto genarate. In order 
# to reduce the current make writing burden. if you 
# are have any question and to see:
# \$(sysbuild_root)/docs/A&Q.txt. 
# About to usage of the this make.mk, you are can 
# to see :
# \$(sysbuild_root)/docs/make_mk.txt
${space}
${space}
# Include others make.mk
# \$(call include-makefiles, /foo/make.mk /boo/make.mk)
${space}
${space}
EOF
}


# Function: mk_write_module_ctx_libs_and_bin
# Module:
#  STATIC_LIBRARYS,SHARED_LIBRARYS,EXECUTABLE, 
#  TEST
# Usage:
# mk_write_module_ctx_libs_and_bin $1 $2 $3 $4 $5...
# $1    : target file name.
# $2    : module name.
# $3    : link mode (c or c++)
# $4    : build type (STATIC_LIBRARY,SHARED_LIBRARY,
#         EXECUTABLE, TEST)
# $5    : enable source files auto finds. (false or true)
# ...   : Find source files paths and if $4 is enabled.
#
mk_write_module_ctx_libs_and_bin()
{
	if [ ! -z $5 ];then
		unset all_src_files
		mk_find_src_files ".cpp .c .cc .CC .S .s"
	fi
cat >> ${1} << EOF
${space}
###################Module '${2}' begin####################
include \$(CLEAR_VARS)
# Declare module name
LOCAL_MODULE := ${2}
# LOCAL_MODULE_FILENAME :=

LOCAL_SRC_FILES := ${all_src_files}

LOCAL_LINK_MODE := ${3}
LOCAL_CFLAGS :=
LOCAL_CPPFLAGS :=
LOCAL_LDFLAGS :=
LOCAL_LDLIBS :=

# Append any include's paths.
LOCAL_C_INCLUDES := \$(LOCAL_PATH) 

# If need to them, the comments can be removed
# LOCAL_CPP_EXTENSION :=
# LOCAL_DEPS_MODULES :=
# LOCAL_WHOLE_STATIC_LIBRARIES :=
# LOCAL_SHARED_LIBRARIES :=
# LOCAL_STATIC_LIBRARIES :=
# LOCAL_EXPORT_CFLAGS :=
# LOCAL_EXPORT_CPPFLAGS :=
# LOCAL_EXPORT_LDFLAGS :=
# LOCAL_EXPORT_C_INCLUDES := 
ifdef TARGET_RELEASE_DIR
# LOCAL_RELEASE_PATH := \$(TARGET_RELEASE_DIR)/....
endif
include \$(BUILD_${4})
###################Module '${2}' end####################
EOF
}

# Function: mk_write_module_ctx_preplibs
# Module:
#  PREBUILT_SHARED_LIBRARY, PREBUILT_STATIC_LIBRARY
# Usage:
# mk_write_module_ctx_preplibs $1 $2 $3 $4
# $1    : target file name.
# $2    : module name.
# $3    : build type (STATIC or SHARED)
# $4    : To point LOCAL_SRC_FILES source.
#
mk_write_module_ctx_preplibs()
{
cat >> ${1} << EOF
${space}
###################Module '${2}' begin ####################
include \$(CLEAR_VARS)
# Declare module name
LOCAL_MODULE := ${2}

LOCAL_SRC_FILES := ${4}

# LOCAL_DEPS_MODULES :=
# LOCAL_EXPORT_CFLAGS :=
# LOCAL_EXPORT_CPPFLAGS :=
# LOCAL_EXPORT_LDFLAGS :=
# LOCAL_EXPORT_C_INCLUDES := 
ifdef TARGET_RELEASE_DIR
# LOCAL_RELEASE_PATH := \$(TARGET_RELEASE_DIR)/....
endif
include \$(PREBUILT_${3}_LIBRARIES)
###################Module '${2}' end ####################
EOF
}


# Function: mk_write_module_ctx_th3
# Module:
#  BUILD_TH3_BINARY
# Usage:
# mk_write_module_ctx_th3 $1 $2 $3
# $1    : target file name.
# $2    : module name.
# $3    : To point target top path.
#
mk_write_module_ctx_th3()
{
cat >> ${1} << EOF
${space}
###################Module '${2}' begin####################
include \$(CLEAR_VARS)
# Declare module name
LOCAL_MODULE := ${2}
LOCAL_TARGET_TOP := ${3}
LOCAL_TARGET_CMD := 
LOCAL_TARGET_COPY_FILES := 
# LOCAL_DEPS_MODULES :=
ifdef TARGET_RELEASE_DIR
# LOCAL_RELEASE_PATH := \$(TARGET_RELEASE_DIR)/....
endif
include \$(BUILD_TH3_BINARY)
###################Module '${2}' end####################
EOF
}

print_help()
{
	 echo "Usage: "
	 echo "./tmake <options>"
	 echo "   Options:"
	 echo "      -m       Specify module name."
	 echo "      -t       Type of the module, one of them:"
	 echo "                 staticlib|sharedlib|exec|test|staticprep|sharedprep|th3"
	 echo "      -n       Target file name."
	 echo "      -l       link mode of the module, either of c or c++, default is c."
	 echo "      -a       Enable automatically search source files with file format"
	 echo "               .c|.cpp|.CC|.cc|.s|.S."
	 echo "      -h       Append a header of the module to target file."
	 echo "      -f       Force to cover target name when it's already exist."
}

if [ -z $1 ];then
	print_help
	exit 0
fi

moduleheader=""

while getopts ":m:t:l:an:hf" opt; do
	case ${opt} in
		n)
			targetname=${OPTARG}
			;;
		m)
		   modulename=${OPTARG}
		   ;;
		t)
		  moduletype=${OPTARG}
		  ;;
		l)
		  modulelinkmode=${OPTARG}
		  ;;
		a)
		  moduleautosrc=1
		  ;;
		h)
		  moduleheader=1
		  ;;
	    f)
		  forceover=1
		  ;;
	esac
done 

if [ "$modulename" == "" ] || [ "$moduletype" == "" ];then
  print_help
  exit 1
fi

if [ "$modulelinkmode" == "" ];then
	 modulelinkmode=c
fi

if [ "$targetname" == "" ];then
   targetname=make.mk
fi

if [  -e $targetname ] && [ ! $forceover ];then
  echo "Target name '${targetname}' already exist."
  exit 0
fi

if [  "$moduleheader" != "" ];then
	mk_write_header $targetname
fi

case $moduletype in 
	staticlib)
		mk_write_module_ctx_libs_and_bin $targetname \
			                             $modulename \
										 $modulelinkmode \
										 STATIC_LIBRARY \
										 $moduleautosrc
    ;;
    sharedlib)
		mk_write_module_ctx_libs_and_bin $targetname \
			                             $modulename \
										 $modulelinkmode \
										 SHARED_LIBRARY \
										 $moduleautosrc
		;;
	exec)
		mk_write_module_ctx_libs_and_bin $targetname \
			                             $modulename \
										 $modulelinkmode \
										 EXECUTABLE \
										 $moduleautosrc
		;;
	test)
		mk_write_module_ctx_libs_and_bin $targetname \
			                             $modulename \
										 $modulelinkmode \
										 TEST \
										 $moduleautosrc
		;;
	staticprep)
		mk_write_module_ctx_preplibs  $targetname \
			                          $modulename \
									  STATIC
		;;
	sharedprep)
		mk_write_module_ctx_preplibs  $targetname \
			                          $modulename \
									  SHARED
		;;
	th3)
		mk_write_module_ctx_th3 $targetname \
			                    $modulename 
		;;
esac
