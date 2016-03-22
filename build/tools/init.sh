#!/bin/sh
unset sys_build_top
sys_build_top=`dirname ${BASH_ARGV[0]}`
sys_build_top=$sys_build_top/../..
sys_build_top=`cd $sys_build_top && pwd`
if [ ! -f $sys_build_top/sys-build  ];then
	sys_build_top=`which sys-build`
	if [ ! -f $sys_build_top/sys-build  ];then
		echo "Error#: Don't to get sys-build root drectory."
		return 1
	fi
fi
. ${sys_build_top}/build/tools/sys-helper.sh

_scan_dentry()
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
log()
{
	:
	#echo "$@"
}
get_sys_build_products_config()
{
	local sys_build_configs=$sys_build_top/build/configs
	local _SYS_BUILD_CONFIG_LIST
	if [ ! -d $sys_build_configs ];then
		log "Incomplete sys-build compilation system."
		exit 1
	fi
	log "Scaning directory  $sys_build_configs ..."
	ALL_ARCHS=`_scan_dentry $sys_build_configs false`
	for arch in ${ALL_ARCHS}
	do
		log "ARCH:$arch"
		local M
		local temp
		temp=`_scan_dentry $sys_build_configs/${arch} false`
		M="ALL_PLATFORMS_${arch}=\"$temp\""
		eval $M
		M="ALL_PLATFORMS_${arch}"
		for plat in ${!M}
		do
			log "  PLATFORM:$plat"
			temp=`_scan_dentry $sys_build_configs/${arch}/${plat} true`
			local D
			D="ALL_BOARDS_${plat}=\"$temp\""
			eval $D
			D="ALL_BOARDS_${plat}"
			local boards
			boards=${!D}
			for board in $boards
			do
				if [ "$board" = "common_config" ];then
					#if common_config then skip it.
					log "Skip common_config."
					continue
				fi
				#must be "_config" suffix
				_board=`echo $board |grep -o -e "_config$"`
				if [ "$_board" = "" ];then
					#invalid format.
					log "Skip invalid string $board."
					continue
				fi
				 unset alias_bd_suffix
				 unset alias_bd
				alias_bd=`find_line APP_ALIAS_BOARDS ${sys_build_configs}/${arch}/${plat}/${board}`
				alias_bd=(${alias_bd[@]})
				if [  ${#alias_bd[*]} -lt 3 ]; then
					alias_bd_suffix=${board}
				else
					# Append _config suffix
					for abd in ${alias_bd[@]:2}
					do
						alias_bd_suffix=(${alias_bd_suffix[*]} ${abd}_config )
					done
				fi
				log "${board} -> ${alias_bd_suffix[@]}"
				_SYS_BUILD_CONFIG_LIST=(${_SYS_BUILD_CONFIG_LIST[*]} ${alias_bd_suffix[@]} )
			done
		done
	done
	echo ${_SYS_BUILD_CONFIG_LIST[*]}
}
unset SYS_BUILD_CONFIG_LIST
SYS_BUILD_CONFIG_LIST=`get_sys_build_products_config`
SYS_BUILD_HELP_LIST=(${SYS_BUILD_HELP_LIST[@]} \
	config help modules \
	tag-so tag-a tag-kernel \
	tag-bootloader tag-test \
	tag-exe tag-th3 make- \
	shell- )


_tab_fill()
{
	local cur prev opts 
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	if [ "$prev" = "config" ];then
		COMPREPLY=( $(compgen -W "${SYS_BUILD_CONFIG_LIST[*]}" -- ${cur}) )
	else
		COMPREPLY=( $(compgen -W "${SYS_BUILD_HELP_LIST[*]}" -- ${cur}) )
	fi
	return 0
}
complete -F _tab_fill sys-build

#if sys-build not in the $PATH
sys-build()
{
	$sys_build_top/sys-build $@
} 
sys-make()
{
	$sys_build_top/build/tools/sys-make.sh $@
} 

