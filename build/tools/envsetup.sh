#!/bin/sh
_PWD=`dirname ${BASH_ARGV[0]}`
. ${_PWD}/sys-helper.sh

unset extra_vars 
unset check_vars
unset all_write_vars
_line_1="-"
_line_2=${_line_1}${_line_1}
_line_4=${_line_2}${_line_2}
_line_8=${_line_4}${_line_4}
_line_16=${_line_8}${_line_8}
_space_1=" "
_space_2=${_space_1}${_space_1}
_space_4=${_space_2}${_space_2}
_space_8=${_space_4}${_space_4}
_space_16=${_space_8}${_space_8}
SYS_BUILD_VERSION_3=2.2
SYS_BUILD_CONTEXT_19="Sys-build Version: "
check_vars=(APP_MODULES APP_ARCH APP_ABI APP_BOARD)

#extra_vars=( \
	#		APP_DEBUG \
	#)
#APP_DEBUG="APP_DEBUG := 1"

all_write_vars=(  \ 
APP_BUILD_SCRIPT \
	APP_OPTIM \
	APP_OUTPUT_DIR \
	APP_DEBUG_MODULES \
	APP_MODULES \
	APP_PLATFORM \
	APP_ARCH \
	APP_ABI \
	APP_BOARD \
	APP_VENDOR \
	APP_WORKSPACE \
	APP_SDK_DIR \
	APP_LSP_DIR \
	APP_RELEASE_DIR \
	APP_STL \
	APP_ALIAS_BOARD \
	APP_TOOLCHAIN_SYSROOT)
create_nots_for_write_vars()
{
	TABLE_NOTES_APP_BUILD_SCRIPT="# Point to a script file.the APP_PROJECT_PATH to record current path."

	#  TABLE_NOTES_APP_MODULES="#if APP_MODULES by defined ,then sys-build\
		#                           only to build these modules."

	TABLE_NOTES_APP_OUTPUT_DIR="# define output directory ,the defalut as follow:\
		\n# $PWD/out."

	TABLE_NOTES_APP_ABI="# defined current ABI(Application Binary Interface),example\
		\n# armeabi(embedded-application binary interface) or armeabi-v7a."
	TABLE_NOTES_APP_DEBUG_MODULES="#APP_DEBUG_MODULES := 1"

	TABLE_NOTES_APP_STL="# Reserved function."

	TABLE_NOTES_APP_ARM_TOOLCHAIN="# defined current Cross-compilation prefix,\
		\n# example 'APP_ARM_TOOLCHAIN := /opt/bin/arm-linux-'." 

	TABLE_NOTES_APP_X86_TOOLCHAIN="# defined current Cross-compilation prefix,
	\n# example 'APP_X86_TOOLCHAIN := /opt/x86/bin/x86-'." 

	TABLE_NOTES_APP_MIPS_TOOLCHAIN="# defined current Cross-compilation prefix,
	\n# example 'APP_MIPS_TOOLCHAIN := /opt/mips/bin/mips-linux-'." 

	TABLE_NOTES_APP_PPC_TOOLCHAIN="# defined current Cross-compilation prefix,\
		\n# example 'APP_PPC_TOOLCHAIN := /opt/ppc/bin/powerpc-linux-'." 

	TABLE_NOTES_APP_WORKSPACE="# 这个变量总是被描述成一个完整的sysdev工程的顶层目录,即，如果目\
		\n# 前只是在某个模块里面进行编译，也应该根据其相对sysdev的位置而计\
		\n# 算出sysdev的顶层目录，并赋值给这个变量. 如果你就在完整的sysdev\
		\n# 工程的顶层目录下进行编译，这个值默认就是当前目录，不需要再另外\
		\n# 赋值.
	\n# 这个值之所以需要这么确定，是因为工程的sdk和linux_lsp的路径是通\
		\n# 过该值计算出来的,如果该变量给的不正确，sys-build会给出警告信息，\
		\n# 如果你确定当前模块不需要使用SDK/LINUX_LSP等路径，可以忽略这些警\
		\n# 告."

	TABLE_NOTES_APP_SDK_DIR="# SDK相对sysdev的路径，每个平台有所差别，统一提供给需要的模块使用模\
		\n# 块本身不应该覆盖定义该变量，以免造成其他模块无法正常引用该变量."

	TABLE_NOTES_APP_LSP_DIR="# Linux_lsp相对sysdev的路径，统一提供给需要的模块使用模块本身不应该\
		\n# 覆盖定义该变量，以免造成其他模块无法正常引用该变量."

	TABLE_NOTES_APP_RELEASE_DIR="# 发布路径的顶层目录，默认就存放在APP_WORKSPACE之下各个模块需要根据\
		\n#《版本发布说明》当中的规则，自行构建自身的发布结构，比如\
		\n# $$(APP_RELEASE_DIR)/cbb/sysdbg/include"

	TABLE_NOTES_APP_TOOLCHAIN_SYSROOT="# Specifyed toolchain sysroot dirctory, \
		\n# it's equivalent to '--sysroot' option."

	TABLE_NOTES_APP_ALIAS_BOARD="# Alias of the target board."
}
update_vars()
{
	local name
	local new_v
	local old_v
	local array
	array=($@)
	name=${array[0]}
	array[0]="$name := "
	new_v=${array[@]}
	for v in ${all_write_vars[@]}
	do 
		if [ $name = $v ];then
			local D
			D="old_v=( \"\${${v}[@]}\")" 
			eval $D
			D="$v=(\"\$new_v\")"
			eval $D
		fi
	done
}

#Function: scan_dentry
#Argument: $1:scan dir
#Argument: $2:if false and scan subs dir in the dir $1 ,without scan file in the $1
#Usage:  rev=scan_dentry $path false
scan_dentry()
{
	target_dir=$1
	scan_file=$2
	if [ ! -d $target_dir ];then 
		return
	fi
	local subsdirs
	for subsdir in `ls $target_dir`
	do
		if [ $scan_file = false ];then
			if [ ! -d $target_dir/$subsdir ];then
				continue
			fi
		else
			if [ ! -f $target_dir/$subsdir ];then
				continue
			fi
		fi
		subsdirs="$subsdirs $subsdir"
	done
	echo $subsdirs
}
unset ALL_ARCHS
scan_dir()
{
	local _all_boards
	local sys_build_configs=$PROGDIR/build/configs 
	if [ ! -d $sys_build_configs ];then
		log "Incomplete sys-build compilation system."
		exit 1
	fi
	log "Scaning directory  $sys_build_configs ..."
	ALL_ARCHS=`scan_dentry $sys_build_configs false`
	for arch in ${ALL_ARCHS}
	do
		log "ARCH:$arch"
		local M
		local temp
		temp=`scan_dentry $sys_build_configs/${arch} false`
		M="ALL_PLATFORMS_${arch}=\"$temp\""
		eval $M
		M="ALL_PLATFORMS_${arch}"
		for plat in ${!M}
		do
			log "  PLATFORM:$plat"
			temp=`scan_dentry $sys_build_configs/${arch}/${plat} true`
			unset _bs
			local _bs
			#filter invalid format
			for _b in $temp
			do
				local b
				b=`echo ${_b} | sed -e 's/_config$//g'`
				if [ $b = $_b ];then 
					continue
				fi
				if [ "$b" = "common" ];then
					continue
				fi	
				_bs=(${_bs[@]} $b)
			done
			local D
			D="ALL_BOARDS_${arch}_${plat}=\"${_bs[@]}\""
			eval $D
			D="ALL_BOARDS_${arch}_${plat}"
			log "   BOARDS:${!D}"
			for bd in ${!D}
			do
				_all_boards=( ${_all_boards[@]} ${bd} )
				alias_bd=`find_line APP_ALIAS_BOARDS ${sys_build_configs}/${arch}/${plat}/${bd}_config`
				alias_bd_array=(${alias_bd[@]})

				if [  ${#alias_bd_array[*]} -lt 3 ]; then
					continue
				fi
				local D
				D="ALL_BOARDS_ALIAS_${arch}_${plat}_${bd}=\"${alias_bd_array[@]:2}\""
				eval $D
				log "     ALIAS_BOARDS: ${bd} -> ${alias_bd_array[@]:2}"
				for alias_bd in ${alias_bd_array[@]:2}
				do
					local D
					D="__alias_bds_${alias_bd}"
					if [ "${!D}" != "" ];then
						log_error "Already exist alias '${alias_bd}' in the ${sys_build_configs}/${arch}/${plat}/${bd}_config"
						exit 1
					fi
					D="__alias_bds_${alias_bd}=${bd}"
					eval $D
				done
			done
		done
	done
	for tbd in ${_all_boards[@]}
	do
		local D
		D="__alias_bds_${tbd}"
		if [ "${!D}" != "" ];then
			log_error "Detection alias '${tbd}' of the board name '${!D}' config with board name '${tbd}' conflict."
			exit 1
		fi
	done
}
find_board()
{
	scan_dir
	local D
	local alias_bd bd
	if ! expr "$1" : ".*_config$" >> /dev/null
	then
		return 1
	fi
	alias_bd=`echo $1 |sed 's/_config$//g'`

	D="__alias_bds_${alias_bd}"
	bd=${!D}
	if [ ! ${bd} ];then
		bd=${alias_bd}
	fi

	for arch in $ALL_ARCHS
	do
		D="ALL_PLATFORMS_${arch}"
		for plat in ${!D}
		do
			M="ALL_BOARDS_${arch}_${plat}"
			for board in ${!M}
			do
				if [ $bd = ${board} ];then
					PRODUCT=" ${arch} ${plat} ${alias_bd}"
					return 0
				fi
			done
		done
	done
}

#Function: find_alias_board
#Parameter: $1: arch name
#Parameter: $2: plat name
#Parameter: $3: board name
#Description :Return all alias of the $3
#Usage: find_alias_board arm am1808 moon90
find_alias_board()
{
	local rev
	if [ ! $1 ] || [ ! $2 ] || [ ! $3 ] ;then
		return
	fi
	local M
	M="ALL_BOARDS_ALIAS_${1}_${2}_${3}"
	echo "${!M}"
}
add_lunch_menu()
{
	local D
	local M
	local temp
	scan_dir
	for arch in $ALL_ARCHS
	do
		D="ALL_PLATFORMS_${arch}"
		for plat in ${!D}
		do
			M="ALL_BOARDS_${arch}_${plat}"
			for board in ${!M}
			do
				temp=${arch}-${plat}-${board}
				add_lunch_combo $temp
			done
		done
	done
}

print_layout_lunch_menu()
{
	local last_words_len=0
	local print_words
	local fill_space_len

	# The most process 80 chars at the terminal.
	# | 4 space chars | 36 title chars | 4 char space | 36 title chars |
	print_words="${1}. ${2}"
	last_words_len=`echo ${#print_words}`
	fill_space_len=$((36-$last_words_len))
	if test `expr $i % 2` == 0
	then
		echo  "${_space_4}${print_words}"
	else
		echo -n -e "${_space_4}${print_words}"
		while [ $fill_space_len -gt 0  ]
		do
			echo -n "${_space_1}"
			fill_space_len=$(($fill_space_len-1))
		done
	fi
}

print_lunch_menu()
{
	add_lunch_menu
	local uname=`uname`
	echo
	echo "You're building on" $uname
	echo
	echo "Lunch menu... pick a combo:"

	local i=1
	local choice
	if [ "${#LUNCH_MENU_CHOICES[@]}" = "0" ];then
		return 1
	fi
	for choice in ${LUNCH_MENU_CHOICES[@]}
	do
		print_layout_lunch_menu $i $choice
		i=$(($i+1))
	done
	# Process '\n' at the end of last line.
	if test `expr $i % 2` == 0
	then
		echo ""
	fi
}

unset LUNCH_MENU_CHOICES

auto_layout_lunch_menu()
{
	add_lunch_menu
	echo "Choose your like architecture: "
	select arch in ${ALL_ARCHS[@]}
	do
		if [ ! -z $arch ];then
			echo "Choose platform: "
			M="ALL_PLATFORMS_${arch}"
			select plat in ${!M}
			do
				if [ ! -z $plat ];then
					echo "Choose board: "
					M="ALL_BOARDS_${arch}_${plat}"
					local alias_bd
					for bd in ${!M}
					do
						_abd=`find_alias_board ${arch} ${plat} ${bd}`
						if [ "${_abd}" == "" ];then
							# if unset alias then using ${bd}.
							_abd=${bd}
						fi
						alias_bd=(${alias_bd[@]} ${_abd})
					done
					select board in ${alias_bd[@]}
					do
						PRODUCT="$arch $plat $board"
						break
					done
				fi
				break
			done
			break
		fi
		break
	done
}

add_lunch_combo()
{
	local new_combo=$1
	local c
	for c in ${LUNCH_MENU_CHOICES[@]}
	do
		if [ "$new_combo" = "$c" ] ; then
			return
		fi
	done
	LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]}  $new_combo)
}
lunch()
{
	local answer

	if [ "$1" ] ; then 
		answer=$1
	else 
		print_lunch_menu
		if [ ! $? = 0 ];then
			return 1
		fi
		echo -n "Which would you like? "
		read answer
	fi   

	local selection=

	if [ -z "$answer" ]
	then 
		selection= #default
	elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
	then 
		if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ]
		then 
			selection=${LUNCH_MENU_CHOICES[$(($answer-1))]}
		fi   

		if [ -z "$selection" ]
		then 
			echo 
			echo "Invalid lunch combo: $answer"
			return 1
		fi   
		local product=$(echo -n $selection | sed -e "s/-/ /g")
		if [ $? -ne 0 ]
		then
			echo
			echo "** Don't have a product spec for: '$product'"
			echo "** Do you have the right repo manifest?"
			return 1
		fi
	fi
	PRODUCT=$product
}

write_file()
{
	local target_file
	local ARCH PLATFORM BOARD
	local _PRODUCT
	local TOP 
	local common_file
	`touch $1`
	if [ ! $? -eq 0 ];then
		log_error "Don't create configuration file '$1'."
		exit 1
	fi
	for v in $PRODUCT
	do
		_PRODUCT=(${_PRODUCT[@]} $v)
	done
	if [ ! ${#_PRODUCT[@]} -eq 3 ];then
		#     echo "The value of the variable PROJECT illegal."
		exit 1
	fi
	TOP=$PROGDIR
	ARCH=${_PRODUCT[0]}
	PLATFORM=${_PRODUCT[1]}
	ALIAS_BOARD=${_PRODUCT[2]}
	local D
	local _isalias
	_isalias=true
	D="__alias_bds_${ALIAS_BOARD}"
	BOARD=${!D}
	if [ "${BOARD}" == "" ]
	then
		_isalias=false
		BOARD=${ALIAS_BOARD}
	fi

	assert_defined  TOP ARCH PLATFORM BOARD
	assert_files $TOP/build/configs/$ARCH/$PLATFORM/${BOARD}_config

	# Search file of the  high prioritiy
	# Add alias config if it's avalid.
	alias_board_config=$TOP/build/configs/$ARCH/$PLATFORM/${ALIAS_BOARD}.alias
	if [ ${_isalias} ] && [ -f $alias_board_config ];then
		target_file=(${target_file[@]} $alias_board_config)
	fi

	target_file=(${target_file[@]}  $TOP/build/configs/$ARCH/$PLATFORM/${BOARD}_config )
	common_file=$TOP/build/configs/$ARCH/$PLATFORM/common_config

	if [ -f $common_file ];then
		target_file=(${target_file[@]} $common_file)
	fi
	# Search file of the  low prioritiy
	target_file=(${target_file[@]} $TOP/build/core/default-application.mk)

	local temp_arch
	case "$ARCH" in
		x86)
			temp_arch=APP_X86_TOOLCHAIN
			;;
		arm)
			temp_arch=APP_ARM_TOOLCHAIN
			;;
		arm64)
			temp_arch=APP_ARM64_TOOLCHAIN
			;;
		mips)
			temp_arch=APP_MIPS_TOOLCHAIN
			;;
		powerpc)
			temp_arch=APP_PPC_TOOLCHAIN
			;;
	esac
	check_defined temp_arch "Unsupport ARCH '$ARCH' at $PROGDIR/build/tools/envsetup.sh."
	all_write_vars=(${all_write_vars[@]} $temp_arch)
	log "Read config form files '${target_file[@]}'"
	for var in ${all_write_vars[@]}
	do
		for file in ${target_file[@]}
		do
			local D temp
			D="temp=\"\${$var}\""
			eval $D
			if [ ! "${temp}" = "" ];then
				log "Variable '$var' already defined,ignore it."
				continue
			fi
			log "find line:$var in the file $file"
			temp=`find_line $var $file`
			if [ ! $? -eq 0 ];then
				exit 1
			fi
			if [ "$temp" = "" ];then
				continue
			fi
			D="$var=(\"\$temp\")"
			eval $D
		done
	done
	APP_ALIAS_BOARD="APP_ALIAS_BOARD := ${ALIAS_BOARD}"
	extra_vars=(${extra_vars[@]})
	all_write_vars=(${all_write_vars[@]} ${extra_vars[@]} )

	local target_modules_path target_modules modules lastkey
	target_modules_path=`dirname $1`

	#target_modules=(`find_line LOCAL_MODULE $target_modules_path/make.mk`)

	for m in ${target_modules[@]}
	do
		if [ "$lastkey" = ":=" ];then
			modules=(${modules[@]} $m )
			lastkey="" 
		else
			lastkey=$m
		fi
	done
	#the function of the experimental,disable it 
	#update_vars "APP_MODULES" "${modules[@]}"


	for check_var in ${check_vars[@]}
	do
		for srcv in ${all_write_vars[@]}
		do
			local name value D temp
			if [ $check_var = $srcv ];then
				name=$check_var
				D="temp=(\"\${${srcv}[@]}\")"
				eval $D
				temp=($temp)
				name=${temp[0]}
				value=${temp[2]}
				assert_eq $srcv $name
				if [ $name = APP_MODULES ];then
					if [ -z $value ];then
						:
					fi 
				fi
			fi
		done
	done

	echo

	create_nots_for_write_vars

	echo "#${_line_16}${_line_16}${_line_4}${_line_2}#"  >> $1
	echo "#${_space_8}${SYS_BUILD_CONTEXT_19}${SYS_BUILD_VERSION_3}${_space_8}#"  >> $1
	echo "#${_line_16}${_line_16}${_line_4}${_line_2}#"  >> $1
	echo "" >> $1

	echo "========================================"
	for var in ${all_write_vars[@]}
	do
		local D
		D="temp=( \"\${${var}[@]}\")"
		eval $D
		if [ "$temp" = "" ];then
			continue
		fi
		echo "$temp"
		D="note_var=\"\$TABLE_NOTES_${var}\""
		eval $D
		if [ ! "$note_var" = "" ] ; then
			echo "" >> $1
			echo -e $note_var >> $1
		fi
		echo "$temp" >> $1
	done
	echo
	echo "========================================"
} #write_file


#if the first parameter is 'config' we will return 1 without return 0.
__sys_build_check_args()
{
	local args

	#filter-out the word of the contain '=' 
	for arg in $@
	do
		if ( echo -n $arg | grep -q "=" );then
			continue
		else
			args=(${args[@]} $arg)
		fi
	done


	#Args 1
	if [ ! "${args[0]}" = "config" ]
	then
		return 0
	fi


	echo  "Configure sys-build ..." 1>&2

	#Args 2
	if [ "${args[1]}" = "" ];then
		#lunch
		auto_layout_lunch_menu
		if [ ! $? = 0 ];then
			exit 1
		fi
	else
		local board_name
		find_board ${args[1]}
		if [ "$PRODUCT" = "" ];then
			log_error "Invalid board config '${args[1]}'" 
			return 1
		fi
	fi


	#well, we are writing config.
	if [ -e ./Application.mk ];then
		`rm -f ./Application.mk  2>/dev/null`
		if [ ! $? -eq 0 ];then
			log_error "Remove file 'Application.mk' failure."
			return 1
		fi
	fi
	write_file ./Application.mk 
	return 1
}
