#!/usr/bin/env bash
set +x
set -euo pipefail
# Install full environment
# MASTER branch

# use curl
# bash <(curl -sL https://raw.githubusercontent.com/andy0mg/DebianLikeBitrixVM/master/r7_centos.sh)

# use wget
# bash <(wget -qO- https://raw.githubusercontent.com/andy0mg/DebianLikeBitrixVM/master/r7_centos7.sh)

cat > /root/temp_install_r7o.sh <<\END
#!/usr/bin/env bash
set +x
set -euo pipefail

yum update
yum install -y nginx
tee /etc/nginx/nginx.conf >/dev/null <<EOF
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
events {
worker_connections 1024;
}
http {
include /etc/nginx/mime.types;
default_type application/octet-stream;
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x_forwarded_for"';
access_log /var/log/nginx/access.log main;
sendfile on;
#tcp_nopush on;
keepalive_timeout 65;
#gzip on;
include /etc/nginx/conf.d/*.conf;
}
EOF
systemctl reload nginx 
yum install epel-release
yum install -y postgresql postgresql-server
service postgresql initdb
chkconfig postgresql on
sed -i 's/127.0.0.1\/32            ident/127.0.0.1\/32            trust/g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/::1\/128                 ident/::1\/128                 trust/g' /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql
cd /tmp
sudo -u postgres psql -c "CREATE USER r7office WITH password 'r7office';"
sudo -u postgres psql -c "CREATE DATABASE r7office OWNER r7office;"
sudo -u postgres psql -c "GRANT ALL privileges ON DATABASE r7office TO r7office;"
cd ~
yum install -y redis
sudo service redis start
sudo systemctl enable redis
yum install -y rabbitmq-server
service rabbitmq-server start
systemctl enable rabbitmq-server
yum install -y cabextract xorg-x11-font-utils
yum install -y fontconfig
rpm -i https://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

yum-config-manager --add-repo https://download.r7-office.ru/repo/centos/main/noarch
cd /etc/pki/rpm-gpg/
wget https://download.r7-office.ru/repo/gpgkey/r7-office.gpg.key
echo "gpgcheck=1 
gpgkey=file:///etc/pki/rpm-gpg/r7-office.gpg.key" >> /etc/yum.repos.d/download.r7-office.ru_repo_centos_main_noarch.repo
yum update
yum makecache
yum install -y r7-office-documentserver-ee

systemctl start ds-docservice.service
systemctl start ds-converter.service
systemctl start ds-metrics.service

systemctl enable ds-docservice.service
systemctl enable ds-converter.service
systemctl enable ds-metrics.service

systemctl start nginx.service
systemctl enable nginx.service
setenforce 0;
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config;
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload


reboot

END

bash /root/temp_install_r7o.sh

rm /root/temp_install_r7o.sh
