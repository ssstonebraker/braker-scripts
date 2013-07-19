#!/bin/bash

BLUE="\033[0;34m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0;m"

DIR=`pwd`
VER_HTTP="2.2.25"
BUILDDIR=$DIR/build

echo $DIR

if [ ! -d $BUILDDIR ]; then
    mkdir $BUILDDIR
fi

if [ ! -d "vendor" ]; then
    mkdir vendor
fi

if [ ! -d "vendor/httpd-$VER_HTTP" ]; then
    printf "$BLUE * $YELLOW Installing Apache $VER_HTTP$RESET"
    pushd vendor > /dev/null 2>&1
    curl -s -O http://www.gtlib.gatech.edu/pub/apache/httpd/httpd-$VER_HTTP.tar.gz
    echo "1e793eb477c65dfa58cdf47f7bf78d8cdff58091 *httpd-$VER_HTTP.tar.gz" > httpd-$VER_HTTP.tar.gz.sha1
    sha1sum -c httpd-$VER_HTTP.tar.gz.sha1
             if [ $? -eq 0 ]; then
                    echo "${process_name} running"
                else
                    echo "Invalid hash!"
        fi
    tar xzf httpd-2.2.24.tar.gz
    printf "."
    pushd httpd-2.2.24 > /dev/null 2>&1
    ./configure --prefix=$BUILDDIR \
        --exec-prefix=$BUILDDIR \
        --enable-modules=all \
        --enable-mods-shared=all \
        --enable-so \
        --enable-suexec \
        --enable-ldap \
        --enable-authnz-ldap \
        --enable-cache --enable-disk-cache --enable-mem-cache --enable-file-cache \
        --enable-ssl --with-ssl \
        --enable-deflate --enable-cgid \
        --enable-proxy --enable-proxy-connect \
        --enable-proxy-http --enable-proxy-ftp \
        --enable-dbd > install.log 2>&1
    printf "."
    make >> install.log 2>&1
    printf "."
    make install >> install.log 2>&1
    printf "."
    popd > /dev/null 2>&1
    popd > /dev/null 2>&1
    pushd $BUILDDIR/conf > /dev/null 2>&1
    sed -i.bak 's/Listen 80/Listen 8888/' httpd.conf
    sed -i.bak 's/LogLevel warn/LogLevel info/' httpd.conf
    sed -i.bak 's/#ServerName www.example.com:80/ServerName localhost/' httpd.conf
    popd > /dev/null 2>&1
    printf "."
    printf " $GREEN [Complete] $RESET\n"
else
    printf "$BLUE * $GREEN Apache already installed $RESET\n"
fi

if [ ! -d "vendor/modsecurity-apache_2.7.4" ]; then
    printf "$BLUE * $YELLOW Installing ModSecurity$RESET"
    pushd vendor > /dev/null 2>&1
    curl -s -O http://www.modsecurity.org/tarball/2.7.4/modsecurity-apache_2.7.4.tar.gz
    tar xzf modsecurity-apache_2.7.4.tar.gz
    printf "."
    pushd modsecurity-apache_2.7.4 > /dev/null 2>&1
    ./configure --prefix=$BUILDDIR --exec-prefix=$BUILDDIR > install.log 2>&1
    printf "."
    make >> install.log 2>&1
    printf "."
    make install >> install.log 2>&1
    printf "."
    cp $BUILDDIR/lib/mod_security2.so $BUILDDIR/modules
    popd > /dev/null 2>&1
    popd > /dev/null 2>&1
    mkdir build/conf/modsecurity
    cp -r modsecurity/* build/conf/modsecurity/

    cat <<EOF >> build/conf/httpd.conf
LoadModule security2_module modules/mod_security2.so

<IfModule security2_module>
  Include conf/modsecurity/*.conf
</IfModule>

<IfModule repsheet_module>
  RepsheetEnabled On
  RepsheetRecorder On
  RepsheetFilter On
  RepsheetGeoIP On
  RepsheetProxyHeaders On
  RepsheetAction Notify
  RepsheetPrefix [repsheet]
  RepsheetRedisTimeout 5
  RepsheetRedisHost localhost
  RepsheetRedisPort 6379
  RepsheetRedisMaxLength 2
  RepsheetRedisExpiry 24
</IfModule>
EOF
    printf " $GREEN [Complete] $RESET\n"
else
    printf "$BLUE * $GREEN ModSecurity already installed $RESET\n"
fi

if [ ! -d "vendor/geoip" ]; then
    printf "$BLUE * $YELLOW Installing GeoIP$RESET"
    pushd vendor > /dev/null 2>&1
    mkdir geoip
    pushd geoip > /dev/null 2>&1
    curl -s -O http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
    gunzip GeoLiteCity.dat.gz
    cp GeoLiteCity.dat ../../build/conf
    curl -s -O http://www.maxmind.com/download/geoip/api/mod_geoip2/mod_geoip2-latest.tar.gz
    tar xzf mod_geoip2-latest.tar.gz
    printf "."
    pushd mod_geoip2_1.2.8 > /dev/null 2>&1
    ../../../build/bin/apxs -i -a -L../../../build/lib -I../../../build/include/ -lGeoIP -c mod_geoip.c > install.log 2>&1
    printf "."
    popd > /dev/null 2>&1
    popd > /dev/null 2>&1
    popd > /dev/null 2>&1

    sed -i.bak '269s/.*/LogFormat "%h %l %u %t \\"%r\\" %>s %b \\"%{GEOIP_COUNTRY_CODE}e %{GEOIP_CITY}e %{GEOIP_REGION_NAME}e %{GEOIP_POSTAL_CODE}e %{GEOIP_LATITUDE}e %{GEOIP_LONGITUDE}e\\"" common/' build/conf/httpd.conf

    cat <<EOF >> build/conf/httpd.conf

<IfModule geoip_module>
  GeoIPEnable On
  GeoIPDBFile `pwd`/build/conf/GeoLiteCity.dat
  GeoIPOutput All
</IfModule>
EOF
    printf " $GREEN [Complete] $RESET\n"
else
    printf "$BLUE * $GREEN GeoIP already installed $RESET\n"
fi