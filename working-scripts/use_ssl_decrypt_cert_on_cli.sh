#!/bin/bash

echo > ~/.trusted-ca-bundle.pem
echo -e "${CYAN}Exporting Root CAs from Keychain${NC}"
security find-certificate -a -p  > ~/.trusted-ca-bundle.pem
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> ~/.trusted-ca-bundle.pem
 
export REQUESTS_CA_BUNDLE=~/.trusted-ca-bundle.pem



grep "REQUESTS_CA_BUNDLE" ~/.bash_profile
if [ $? -eq 0 ]; then
   echo "REQUESTS_CA_BUNDLE found!"
else
   echo "REQUESTS_CA_BUNDLE not found... adding to ~/.bash_profile"
   echo "export REQUESTS_CA_BUNDLE=~/.trusted-ca-bundle.pem" >> ~/.bash_profile
   source ~/.bash_profile
   echo "REQUESTS_CA_BUNDLE added to source profile and sourced"
fi
