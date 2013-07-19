#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#    http://www.apache.org/licenses/LICENSE-2.0
#    
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.

# Redirect TCP/IP traffic to a particular IP address from one port to another
# port. This is useful to handle incoming traffic on a standard reserved port
# like 80 or 443 for example in an unprivileged user process bound to a non
# reserved port.
# Example: ip-redirect 80 8090 10.1.1.1

sport=$1
tport=$2
dest=$3

# Redirect external incoming traffic
sudo /sbin/iptables -t nat -S PREROUTING | grep "\-d $dest/" | grep "\-p tcp" | grep "\-\-dport $sport" | grep "\-j DNAT" | sed "s/^-A/-D/" | awk -F "\t" '{ printf "sudo /sbin/iptables -t nat %s\n", $1 }' | /bin/sh
sudo /sbin/iptables -t nat -A PREROUTING --destination $dest -p tcp --dport $sport -j DNAT --to $dest:$tport

# Redirect local traffic as well
sudo /sbin/iptables -t nat -S OUTPUT | grep "\-d $dest/" | grep "\-p tcp" | grep "\-\-dport $sport" | grep "\-j DNAT" | sed "s/^-A/-D/" | awk -F "\t" '{ printf "sudo /sbin/iptables -t nat %s\n", $1 }' | /bin/sh
sudo /sbin/iptables -t nat -A OUTPUT --destination $dest -p tcp --dport $sport -j DNAT --to $dest:$tport
