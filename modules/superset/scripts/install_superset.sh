#!/bin/bash
#set -x

SAMPLES=${load_samples}

sudo dnf install -y python3.11 python3.11-pip httpd
sudo dnf install -y gcc gcc-c++ libffi-devel python3.11-devel python3.11-wheel openssl-devel cyrus-sasl-devel openldap-devel
export PYTHONPATH=$PYTHONPATH:/home/opc/python
pip3.11 install Flask-WTF --user --no-input
pip3.11 install sqlparse --user --no-input
pip3.11 install gevent --user --no-input
pip3.11 install gunicorn --user --no-input
pip3.11 install werkzeug --user --no-input
pip3.11 install gevent --user --no-input
pip3.11 install pillow --user --no-input
pip3.11 install apache-superset --user --no-input
pip3.11 install mysql-connector-python --user --no-input
pip3.11 install mysqlclient --user --no-input
pip3.11 install pymysql --user --no-input

export FLASK_APP=superset.app
/home/opc/.local/bin/flask fab create-admin --username "${superset_admin_username}" --firstname "admin" --lastname "admin" --email "nomail@acme.org" --password "${superset_admin_password}"
/home/opc/.local/bin/superset db upgrade
# there is an alambic issue https://github.com/apache/superset/issues/20685
#mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "alter table  ${superset_schema}.dbs drop check dbs_chk_9;"
# fix another issue
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "update ${superset_schema}.alembic_version set version_num='cbe71abde154';"
/home/opc/.local/bin/superset db upgrade
/home/opc/.local/bin/superset init

if [ "$SAMPLES" == "true" ]
then
  /home/opc/.local/bin/superset load-examples
  echo "Superset examples loaded !"
fi

mkdir -p /home/opc/.local/run/superset/ 

sudo mv ~opc/superset.service   /etc/systemd/system/superset.service
sudo mv ~opc/25-superset.conf   /etc/httpd/conf.d/
sudo chown root. /etc/systemd/system/superset.service
sudo chcon system_u:object_r:systemd_unit_file_t:s0 /etc/systemd/system/superset.service
sudo systemctl daemon-reload
sudo systemctl start superset
sudo systemctl start httpd

echo "Superset installed and started !"
