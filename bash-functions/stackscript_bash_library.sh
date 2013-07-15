
#!/bin/bash
#
# StackScript Bash Library
#
# Copyright (c) 2010 Linode LLC / Christopher S. Aker <caker@linode.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# * Neither the name of Linode LLC nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific prior
# written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS &quot;AS IS&quot; AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.

###########################################################
# System
###########################################################

function system_update {
	apt-get update
	apt-get -y install aptitude
	aptitude -y full-upgrade
}

function system_primary_ip {
	# returns the primary IP assigned to eth0
	echo $(ifconfig eth0 | awk -F: '/inet addr:/ {print $2}' | awk '{ print $1 }')
}

function get_rdns {
	# calls host on an IP address and returns its reverse dns

	if [ ! -e /usr/bin/host ]; then
		aptitude -y install dnsutils > /dev/null
	fi
	echo $(host $1 | awk '/pointer/ {print $5}' | sed 's/\.$//')
}

function get_rdns_primary_ip {
	# returns the reverse dns of the primary IP assigned to this system
	echo $(get_rdns $(system_primary_ip))
}

###########################################################
# Postfix
###########################################################

function postfix_install_loopback_only {
	# Installs postfix and configure to listen only on the local interface. Also
	# allows for local mail delivery

	echo &quot;postfix postfix/main_mailer_type select Internet Site&quot; | debconf-set-selections
	echo &quot;postfix postfix/mailname string localhost&quot; | debconf-set-selections
	echo &quot;postfix postfix/destinations string localhost.localdomain, localhost&quot; | debconf-set-selections
	aptitude -y install postfix
	/usr/sbin/postconf -e &quot;inet_interfaces = loopback-only&quot;
	#/usr/sbin/postconf -e &quot;local_transport = error:local delivery is disabled&quot;

	touch /tmp/restart-postfix
}


###########################################################
# Apache
###########################################################

function apache_install {
	# installs the system default apache2 MPM
	aptitude -y install apache2

	a2dissite default # disable the interfering default virtualhost

	# clean up, or add the NameVirtualHost line to ports.conf
	sed -i -e 's/^NameVirtualHost \*$/NameVirtualHost *:80/' /etc/apache2/ports.conf
	if ! grep -q NameVirtualHost /etc/apache2/ports.conf; then
		echo 'NameVirtualHost *:80' > /etc/apache2/ports.conf.tmp
		cat /etc/apache2/ports.conf >> /etc/apache2/ports.conf.tmp
		mv -f /etc/apache2/ports.conf.tmp /etc/apache2/ports.conf
	fi
}

function apache_tune {
	# Tunes Apache's memory to use the percentage of RAM you specify, defaulting to 40%

	# $1 - the percent of system memory to allocate towards Apache

	if [ ! -n &quot;$1&quot; ];
		then PERCENT=40
		else PERCENT=&quot;$1&quot;
	fi

	aptitude -y install apache2-mpm-prefork
	PERPROCMEM=10 # the amount of memory in MB each apache process is likely to utilize
	MEM=$(grep MemTotal /proc/meminfo | awk '{ print int($2/1024) }') # how much memory in MB this system has
	MAXCLIENTS=$((MEM*PERCENT/100/PERPROCMEM)) # calculate MaxClients
	MAXCLIENTS=${MAXCLIENTS/.*} # cast to an integer
	sed -i -e &quot;s/\(^[ \t]*MaxClients[ \t]*\)[0-9]*/\1$MAXCLIENTS/&quot; /etc/apache2/apache2.conf

	touch /tmp/restart-apache2
}

function apache_virtualhost {
	# Configures a VirtualHost

	# $1 - required - the hostname of the virtualhost to create 

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;apache_virtualhost() requires the hostname as the first argument&quot;
		return 1;
	fi

	if [ -e &quot;/etc/apache2/sites-available/$1&quot; ]; then
		echo /etc/apache2/sites-available/$1 already exists
		return;
	fi

	mkdir -p /srv/www/$1/public_html /srv/www/$1/logs

	echo &quot;<VirtualHost *:80>&quot; > /etc/apache2/sites-available/$1
	echo &quot;    ServerName $1&quot; >> /etc/apache2/sites-available/$1
	echo &quot;    DocumentRoot /srv/www/$1/public_html/&quot; >> /etc/apache2/sites-available/$1
	echo &quot;    ErrorLog /srv/www/$1/logs/error.log&quot; >> /etc/apache2/sites-available/$1
    echo &quot;    CustomLog /srv/www/$1/logs/access.log combined&quot; >> /etc/apache2/sites-available/$1
	echo &quot;</VirtualHost>&quot; >> /etc/apache2/sites-available/$1

	a2ensite $1

	touch /tmp/restart-apache2
}

function apache_virtualhost_from_rdns {
	# Configures a VirtualHost using the rdns of the first IP as the ServerName

	apache_virtualhost $(get_rdns_primary_ip)
}


function apache_virtualhost_get_docroot {
	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;apache_virtualhost_get_docroot() requires the hostname as the first argument&quot;
		return 1;
	fi

	if [ -e /etc/apache2/sites-available/$1 ];
		then echo $(awk '/DocumentRoot/ {print $2}' /etc/apache2/sites-available/$1 )
	fi
}

###########################################################
# mysql-server
###########################################################

function mysql_install {
	# $1 - the mysql root password

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;mysql_install() requires the root pass as its first argument&quot;
		return 1;
	fi

	echo &quot;mysql-server-5.1 mysql-server/root_password password $1&quot; | debconf-set-selections
	echo &quot;mysql-server-5.1 mysql-server/root_password_again password $1&quot; | debconf-set-selections
	apt-get -y install mysql-server mysql-client

	echo &quot;Sleeping while MySQL starts up for the first time...&quot;
	sleep 5
}

function mysql_tune {
	# Tunes MySQL's memory usage to utilize the percentage of memory you specify, defaulting to 40%

	# $1 - the percent of system memory to allocate towards MySQL

	if [ ! -n &quot;$1&quot; ];
		then PERCENT=40
		else PERCENT=&quot;$1&quot;
	fi

	sed -i -e 's/^#skip-innodb/skip-innodb/' /etc/mysql/my.cnf # disable innodb - saves about 100M

	MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo) # how much memory in MB this system has
	MYMEM=$((MEM*PERCENT/100)) # how much memory we'd like to tune mysql with
	MYMEMCHUNKS=$((MYMEM/4)) # how many 4MB chunks we have to play with

	# mysql config options we want to set to the percentages in the second list, respectively
	OPTLIST=(key_buffer sort_buffer_size read_buffer_size read_rnd_buffer_size myisam_sort_buffer_size query_cache_size)
	DISTLIST=(75 1 1 1 5 15)

	for opt in ${OPTLIST[@]}; do
		sed -i -e &quot;/\[mysqld\]/,/\[.*\]/s/^$opt/#$opt/&quot; /etc/mysql/my.cnf
	done

	for i in ${!OPTLIST[*]}; do
		val=$(echo | awk &quot;{print int((${DISTLIST[$i]} * $MYMEMCHUNKS/100))*4}&quot;)
		if [ $val -lt 4 ]
			then val=4
		fi
		config=&quot;${config}\n${OPTLIST[$i]} = ${val}M&quot;
	done

	sed -i -e &quot;s/\(\[mysqld\]\)/\1\n$config\n/&quot; /etc/mysql/my.cnf

	touch /tmp/restart-mysql
}

function mysql_create_database {
	# $1 - the mysql root password
	# $2 - the db name to create

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;mysql_create_database() requires the root pass as its first argument&quot;
		return 1;
	fi
	if [ ! -n &quot;$2&quot; ]; then
		echo &quot;mysql_create_database() requires the name of the database as the second argument&quot;
		return 1;
	fi

	echo &quot;CREATE DATABASE $2;&quot; | mysql -u root -p$1
}

function mysql_create_user {
	# $1 - the mysql root password
	# $2 - the user to create
	# $3 - their password

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;mysql_create_user() requires the root pass as its first argument&quot;
		return 1;
	fi
	if [ ! -n &quot;$2&quot; ]; then
		echo &quot;mysql_create_user() requires username as the second argument&quot;
		return 1;
	fi
	if [ ! -n &quot;$3&quot; ]; then
		echo &quot;mysql_create_user() requires a password as the third argument&quot;
		return 1;
	fi

	echo &quot;CREATE USER '$2'@'localhost' IDENTIFIED BY '$3';&quot; | mysql -u root -p$1
}

function mysql_grant_user {
	# $1 - the mysql root password
	# $2 - the user to bestow privileges 
	# $3 - the database

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;mysql_create_user() requires the root pass as its first argument&quot;
		return 1;
	fi
	if [ ! -n &quot;$2&quot; ]; then
		echo &quot;mysql_create_user() requires username as the second argument&quot;
		return 1;
	fi
	if [ ! -n &quot;$3&quot; ]; then
		echo &quot;mysql_create_user() requires a database as the third argument&quot;
		return 1;
	fi

	echo &quot;GRANT ALL PRIVILEGES ON $3.* TO '$2'@'localhost';&quot; | mysql -u root -p$1
	echo &quot;FLUSH PRIVILEGES;&quot; | mysql -u root -p$1

}

###########################################################
# PHP functions
###########################################################

function php_install_with_apache {
	aptitude -y install php5 php5-mysql libapache2-mod-php5
	touch /tmp/restart-apache2
}

function php_tune {
	# Tunes PHP to utilize up to 32M per process

	sed -i'-orig' 's/memory_limit = [0-9]\+M/memory_limit = 32M/' /etc/php5/apache2/php.ini
	touch /tmp/restart-apache2
}

###########################################################
# Wordpress functions
###########################################################

function wordpress_install {
	# installs the latest wordpress tarball from wordpress.org

	# $1 - required - The existing virtualhost to install into

	if [ ! -n &quot;$1&quot; ]; then
		echo &quot;wordpress_install() requires the vitualhost as its first argument&quot;
		return 1;
	fi

	if [ ! -e /usr/bin/wget ]; then
		aptitude -y install wget
	fi

	VPATH=$(apache_virtualhost_get_docroot $1)

	if [ ! -n &quot;$VPATH&quot; ]; then
		echo &quot;Could not determine DocumentRoot for $1&quot;
		return 1;
	fi

	# download, extract, chown, and get our config file started
	cd $VPATH
	wget http://wordpress.org/latest.tar.gz
	tar xfz latest.tar.gz
	chown -R www-data: wordpress/
	cd $VPATH/wordpress
	cp wp-config-sample.php wp-config.php
	chown www-data wp-config.php
	chmod 640 wp-config.php

	# database configuration
	WPPASS=$(randomString 20)
	mysql_create_database &quot;$DB_PASSWORD&quot; wordpress
	mysql_create_user &quot;$DB_PASSWORD&quot; wordpress &quot;$WPPASS&quot;
	mysql_grant_user &quot;$DB_PASSWORD&quot; wordpress wordpress

	# configuration file updates
	for i in {1..4}
		do sed -i &quot;0,/put your unique phrase here/s/put your unique phrase here/$(randomString 50)/&quot; wp-config.php
	done

	sed -i 's/database_name_here/wordpress/' wp-config.php
	sed -i 's/username_here/wordpress/' wp-config.php
	sed -i &quot;s/password_here/$WPPASS/&quot; wp-config.php

	# http://downloads.wordpress.org/plugin/wp-super-cache.0.9.8.zip
}

###########################################################
# Other niceties!
###########################################################

function goodstuff {
	# Installs the REAL vim, wget, less, and enables color root prompt and the &quot;ll&quot; list long alias

	aptitude -y install wget vim less
	sed -i -e 's/^#PS1=/PS1=/' /root/.bashrc # enable the colorful root bash prompt
	sed -i -e &quot;s/^#alias ll='ls -l'/alias ll='ls -al'/&quot; /root/.bashrc # enable ll list long alias <3
}


###########################################################
# utility functions
###########################################################

function restartServices {
	# restarts services that have a file in /tmp/needs-restart/

	for service in $(ls /tmp/restart-* | cut -d- -f2-10); do
		/etc/init.d/$service restart
		rm -f /tmp/restart-$service
	done
}

function randomString {
	if [ ! -n &quot;$1&quot; ];
		then LEN=20
		else LEN=&quot;$1&quot;
	fi

	echo $(</dev/urandom tr -dc A-Za-z0-9 | head -c $LEN) # generate a random string
}
