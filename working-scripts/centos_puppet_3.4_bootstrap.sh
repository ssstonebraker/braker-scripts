#!/bin/bash

echo "executing puppet bootstrap"
if cat /etc/*release | grep -e "CentOS" -e "Red Hat" &> /dev/null; then

#installing this package gives use the key
sudo rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-6.noarch.rpm
cat > /etc/yum.repos.d/puppetlabs.repo <<- "EOF"
[puppetlabs-products]
name=Puppet Labs Products El 6 - $basearch
baseurl=http://yum.puppetlabs.com/el/6/products/$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1
exclude=puppet-2* puppet-3.0* puppet-3.1* puppet-3.2* puppet-3.3*

[puppetlabs-deps]
name=Puppet Labs Dependencies - $basearch
baseurl=http://yum.puppetlabs.com/el/6/dependencies/$basearch
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
enabled=1
gpgcheck=1
EOF

yum update -y

# NOTE: enable the optional-rpms channel (if not already enabled)
yum-config-manager --enable rhel-6-server-optional-rpms

# NOTE: we preinstall lsb_release to ensure facter sets lsbdistcodename
yum install -y redhat-lsb-core git puppet
fi
