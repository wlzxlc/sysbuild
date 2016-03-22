#!/bin/sh

# Print a error
log_error() 
{
	echo "SYS-BUILD:ERROR: $@" 1>&2 
}

# Print a warning
log_warning()
{
	echo "SYS-BUILD:WARNING: $@" 1>&2
}

# Print a info
log_info()
{
	echo "SYS-BUILD:INFO: $@" 1>&2
}

# Assert a file
assert_files()
{
	for file in $@
	do
		if [ ! -f $file  ];then
			log_error "Path '$file' point an invalid file."
			log_error "Abort..."
			exit 1
		fi
	done 
}

# Assert a defined
assert_defined()
{
	local _temp D
	for v in $@
	do
		D="_temp=\${$v}"
		eval $D
		if [ -z ${_temp} ];then
			log_error "Variable '$v' Undefined."
			log_error "Aborting..."
			exit 1
		fi
	done
}

# Check a defined with a error info.
check_defined ()
{
	local _temp D
	D="_temp=\${$1}"
	eval $D
	if [ -z ${_temp} ];then
		log_error "$2"
		log_error "Abort..."
		exit 1
	fi
}

# Assert a expr with a warning and return value.
assert_eq()
{
	if [ "$1" != "$2" ];then
		log_warning "The value '$2' not equal '$1' expected."
		return 1
	fi
}

#Function: find_line
#Parameter: $1: key words
#Parameter: $2: target file
#Description :Return a line of the  hava key words 
#Usage: find_line key_words file
find_line()
{
	local key file revs
	key=$1
	file=$2
	assert_defined file
	assert_files $file
	revs=(`sed -n  '/^'${key}'/p'   $file`)
	if [ ${#revs[@]} -eq 0 ];then
		return
	fi
	assert_eq $key ${revs[0]}
	if [ $? != 0 ];then
		#log_error "$file:'${revs[@]}':Miss Syntax."
		#log_error "Abort..."
		#exit 1
		return
	fi 
	assert_eq ":=" ${revs[1]}
	if [ $? != 0 ];then
		log_error "Error:$file:${revs[$((${#revs[@]}-1))]}:Miss Syntax."
		log_error "Abort..." 1>&2
		exit 1
	fi
	echo ${revs[@]}
} 

