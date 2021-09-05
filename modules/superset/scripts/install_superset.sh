#!/bin/bash
#set -x

SAMPLES=${load_samples}

dnf install -y python38 python38-pip
dnf install -y gcc gcc-c++ libffi-devel python38-devel python38-pip python38-wheel openssl-devel cyrus-sasl-devel openldap-devel
pip3.8 install apache-superset --no-input
pip3.8 install mysql-connector-python --no-input
export PYTHONPATH=$PYTHONPATH:/root/python
pip3.8 uninstall Flask-WTF --no-input
pip3.8 install Flask-WTF==0.14.3 --no-input
pip3.8 install gunicorn==20.0.2 --no-input
pip3.8 install gevent --no-input
pip3.8 install pillow --no-input

export FLASK_APP=superset.app
/usr/local/bin/flask fab create-admin --username "${superset_admin_username}" --firstname "admin" --lastname "admin" --email "nomail@acme.org" --password "${superset_admin_password}"
/usr/local/bin/superset db upgrade
/usr/local/bin/superset init

if [ "$SAMPLES" == "true" ]
then
  /usr/local/bin/superset load-examples
  echo "Superset examples loaded !"
fi

mv ~opc/superset.service   /etc/systemd/system/superset.service
chown root. /etc/systemd/system/superset.service
chcon system_u:object_r:systemd_unit_file_t:s0 /etc/systemd/system/superset.service
systemctl daemon-reload
systemctl start superset

echo "Superset installed and started !"
