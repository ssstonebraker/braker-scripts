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

# Redirect TCP/IP traffic to all local addresses from one port to another
# Example: ip-redirect-all 80 8090

here=`echo "import os; print os.path.realpath('$0')" | python`; here=`dirname $here`
sport=$1
tport=$2

# Cleanup existing rules
sudo /sbin/iptables -t nat -S PREROUTING | grep "\-p tcp" | grep "\-\-dport $sport" | grep "\-j REDIRECT" | sed "s/^-A/-D/" | awk -F "\t" '{ printf "sudo /sbin/iptables -t nat %s\n", $1 }' | /bin/sh
sudo /sbin/iptables -t nat -S OUTPUT | grep "\-p tcp" | grep "\-\-dport $sport" | grep "\-j REDIRECT" | sed "s/^-A/-D/" | awk -F "\t" '{ printf "sudo /sbin/iptables -t nat %s\n", $1 }' | /bin/sh

# Redirect traffic
/sbin/ifconfig | grep "inet addr:" | awk -F ":" '{ print $2 }' | awk '{ print $1 }' | xargs -i $here/ip-redirect $sport $tport {}
