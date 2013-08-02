#!/bin/sh
# install chef solo
# Don't prompt during installs
export DEBIAN_FRONTEND=noninteractive

# Enable Opscode repository
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | tee /etc/apt/sources.list.d/opscode.list

# Upgrade the system
apt-get update
apt-get upgrade -y

# Install Opscode key and update database again
apt-get install --allow-unauthenticated -y opscode-keyring 
apt-get update

# Install chef
apt-get install -y chef

# We don't need Chef Client for Chef Solo, so shut it off
/etc/init.d/chef-client stop
update-rc.d -f chef-client remove