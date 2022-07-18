#!/bin/bash
#set -x

firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=home --permanent --add-port=8000/tcp
firewall-cmd --reload

/usr/bin/checkmodule -M -m -o /home/opc/superset.mod /home/opc/superset.te
/usr/bin/semodule_package -o /home/opc/superset.pp -m /home/opc/superset.mod
/usr/sbin/semodule -i /home/opc/superset.pp

echo "Local Security Granted !"
