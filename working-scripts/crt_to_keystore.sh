	#!/bin/bash
	# Filename: crt_to_keystore.sh
	# Description: create tomcat keystore from cert and key
	# Usage: "Usage: ./crt_to_keystore.sh <path_to_crt> <path_to_key>"
	# Author: Steve Stonebraker
	# pretty printing functions
	function print_status { echo -e "\x1B[01;34m[*]\x1B[0m $1"; }
	function print_good { echo -e "\x1B[01;32m[*]\x1B[0m $1"; }
	function print_error { echo -e "\x1B[01;31m[*]\x1B[0m $1"; }
	function print_notification { echo -e "\x1B[01;33m[*]\x1B[0m $1"; }
	function printline { hr=-------------------------------------------------------------------------------------------------------------------------------
	printf '%s\n' "${hr:0:${COLUMNS:-$(tput cols)}}"
	}
	####################################
	# print message and exit program
	function die { print_error "$1" >&2;exit 1; }
	####################################
	# function that is called when the script exits
	function finish {
		[ -f $(dirname $0)/temp.p12 ] && shred -u $(dirname $0)/temp.p12;
	}

	#whenver the script exits call the function "finish"
	trap finish EXIT
	#######################################
	# if file exists remove it
	function move_file_if_exist {
	  [ -e $1 ] && mv $1 $1.old && print_status "moved file $1 to $1.old";
	}
	#######################################
	# Verify user provided valid file
	function file_must_exist {
	  [ ! -f $1 ] && die "$1 is not a valid file, please provide a valid file name!  Exiting....";
	  print_status "$1 is a valid file"
	}
	#######################################
	# Verify user provided two arguments
	# Verify user provided two arguments
	[ $# -ne 2 ] && die "Usage: ./crt_to_keystore.sh <path_to_crt> <path_to_key>";

	#assign user's provided input to variables
	crt=$1
	key=$2
	#read -p "Provide password to export .crt and .key: " key_pw
	read -p "Provide password for new keystore: " pw

	# Get current path
	readonly ourPath="$(dirname $0)"
	readonly gdbundle="$ourPath/gd_bundle.crt"
	readonly keystore="$ourPath/tomcat.keystore"
	readonly p12="$ourPath/temp.p12"
	readonly KEYTOOL=$(which keytool)
	readonly OPENSSL=$(which openssl)

	printline
	move_file_if_exist ${keystore}

	# Verify gd_bundle.crt exists
	[ ! -f "$gdbundle" ] && die "gd_bundle.crt must exist in current path!  Exiting....";

	#Check to make sure the user provided valid files
	print_status "found gd_bundle.crt in current path"
	file_must_exist ${crt}
	file_must_exist ${key}

	printline
	print_status "Exporting your key and cert to pkcs12 format..."
	${OPENSSL} pkcs12 -export -inkey ${key} -in ${crt} -out ${p12} -password pass:${pw}

	[ ! $? -eq 0 ] && die "Error running command... Exiting!";


	print_status "Importing p12 file to java key store..."

	${KEYTOOL} -importkeystore \
	-srckeystore ${p12} \
	-srcstoretype PKCS12 \
	-destkeystore ${keystore} \
	-keypass ${pw} \
	-storepass ${pw} \
	-srcstorepass ${pw} \
	-dest‐storepass ${pw}  >/dev/null 2>/dev/null
	[ ! $? -eq 0 ] && die "Error running command... Exiting!";

	print_status "Importing godaddy cert to java key store..."

	${KEYTOOL} -import \
	-alias intermed \
	-keystore ${keystore} \
	-trustcacerts \
	-file ${gdbundle} \
	-keypass ${pw} \
	-storepass ${pw}  >/dev/null 2>/dev/null
	[ ! $? -eq 0 ] && die "Error running command... Exiting!";

	print_status "Renaming alias 1 to tomcat"

	${KEYTOOL} -changealias -alias 1 \
	-destalias tomcat \
	-keystore ${keystore} \
	-keypass ${pw} \
	-storepass ${pw}
	[ ! $? -eq 0 ] && die "Error running command... Exiting!";
	#print_status "Listing keystore contents:"
	#${KEYTOOL} -list -v \
	#-keystore ${keystore} \
	#-storepass ${pw}

	printline
	print_good "Keystore ${keystore} creation complete!"
	printline
	print_status "Don't forget to copy ${keystore} to /etc/tomcat7/tomcat.keystore and update server.xml"
	printline





