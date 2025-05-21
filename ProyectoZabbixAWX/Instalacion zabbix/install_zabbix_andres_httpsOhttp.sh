#!/bin/bash

set -euo pipefail

ZBX_IP="157.56.183.200"
ZBX_DB="zabbix"
ZBX_USER="zabbix"
ZBX_PASS="zabbix"
CERT_DIR="/etc/ssl/zabbix"
NGINX_CONF="/etc/nginx/conf.d/zabbix.conf"
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"
ZBX_CONF_PHP="/usr/share/zabbix/ui/conf/zabbix.conf.php"

echo "❓ ¿Quieres instalar Zabbix con HTTPS o HTTP?"
read -rp "[https/http]: " PROTO

echo "🚫 [REMOVE] Desinstalando instalaciones previas..."
systemctl stop zabbix-server zabbix-agent nginx php-fpm || true
dnf remove -y zabbix-* postgresql-server nginx || true
rm -rf /var/lib/pgsql /etc/zabbix "$NGINX_CONF" "$CERT_DIR" "$ZBX_CONF_PHP"
dnf clean all

echo "📦 [REPO] Añadiendo repositorio de Zabbix..."
rpm -Uvh https://repo.zabbix.com/zabbix/7.2/release/rhel/9/noarch/zabbix-release-latest-7.2.el9.noarch.rpm

echo "📦 [PKG] Instalando Zabbix, PostgreSQL, NGINX y PHP..."
dnf install -y zabbix-server-pgsql zabbix-web-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent postgresql-server nginx php php-pgsql php-fpm openssl

echo "🛠️ [DB] Inicializando PostgreSQL..."
postgresql-setup --initdb
systemctl enable --now postgresql

echo "🧑‍💻 [DB] Creando usuario y base de datos Zabbix..."
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${ZBX_USER}') THEN
      CREATE ROLE ${ZBX_USER} WITH LOGIN PASSWORD '${ZBX_PASS}';
   END IF;
END
\$\$;
EOF

sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '${ZBX_DB}';" | grep -q 1 || \
sudo -u postgres createdb -O "${ZBX_USER}" "${ZBX_DB}"

echo "🔐 [DB] Configurando pg_hba.conf..."
sed -i 's/^\(local\s\+all\s\+all\s\+\)peer/\1md5/' "$PG_HBA"
sed -i 's/^\(host\s\+all\s\+all\s\+127\.0\.0\.1\/32\s\+\)ident/\1md5/' "$PG_HBA"
sed -i 's/^\(host\s\+all\s\+all\s\+::1\/128\s\+\)ident/\1md5/' "$PG_HBA"
systemctl restart postgresql

echo "🧩 [DB] Importando esquema..."
PGPASSWORD="${ZBX_PASS}" zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | psql -U ${ZBX_USER} -d ${ZBX_DB}

echo "⚙️ [ZBX] Configurando zabbix_server.conf..."
sed -i "s/^# DBPassword=/DBPassword=${ZBX_PASS}/" /etc/zabbix/zabbix_server.conf

echo "🧪 [PHP] Creando info.php para prueba..."
echo "<?php phpinfo(); ?>" > /usr/share/zabbix/ui/info.php

echo "🛠️ [ZBX] Creando zabbix.conf.php (configuración automática)..."
mkdir -p "$(dirname "$ZBX_CONF_PHP")"
cat > "$ZBX_CONF_PHP" <<EOF
<?php
\$DB['TYPE']     = 'POSTGRESQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '5432';
\$DB['DATABASE'] = '${ZBX_DB}';
\$DB['USER']     = '${ZBX_USER}';
\$DB['PASSWORD'] = '${ZBX_PASS}';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Zabbix Server';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF

echo "🌐 [NGINX] Generando configuración..."

if [[ "$PROTO" == "https" ]]; then
  echo "🔏 [SSL] Generando certificado autofirmado..."
  mkdir -p "$CERT_DIR"
  openssl req -x509 -nodes -days 1825 -newkey rsa:2048 \
    -keyout "$CERT_DIR/zabbix.key" -out "$CERT_DIR/zabbix.crt" \
    -subj "/C=ES/ST=None/L=None/O=Zabbix/CN=${ZBX_IP}"

  cat > "$NGINX_CONF" <<EOF
server {
    listen       443 ssl;
    server_name  ${ZBX_IP};

    ssl_certificate      ${CERT_DIR}/zabbix.crt;
    ssl_certificate_key  ${CERT_DIR}/zabbix.key;

    root /usr/share/zabbix/ui;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \\.php\$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

else
  echo "🌐 [NGINX] Configurando solo HTTP (puerto 80)..."
  cat > "$NGINX_CONF" <<EOF
server {
    listen 80 default_server;
    server_name localhost;

    root /usr/share/zabbix/ui;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \\.php\$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF
fi

echo "🚀 [START] Habilitando servicios..."
systemctl enable --now zabbix-server zabbix-agent nginx php-fpm

if [[ "$PROTO" == "https" ]]; then
  echo "✅ Accede a Zabbix: https://${ZBX_IP}/"
  echo "✅ Accede a info.php: https://${ZBX_IP}/info.php"
else
  echo "✅ Accede a Zabbix: http://${ZBX_IP}/"
  echo "✅ Accede a info.php: http://${ZBX_IP}/info.php"
fi
