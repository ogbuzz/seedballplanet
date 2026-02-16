#!/bin/bash

# Script d'installation Apache2 pour SeedballPlanet.com
# Usage: sudo ./setup-apache.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Ce script doit être exécuté avec sudo"
    exit 1
fi

# Récupérer le vrai nom d'utilisateur (pas root)
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$REAL_USER)

echo "=== Installation Apache2 pour SeedballPlanet.com ==="
echo "Utilisateur: $REAL_USER"
echo "Dossier home: $USER_HOME"
echo ""

# 1. Installer Apache2
echo "[1/9] Installation d'Apache2..."
apt update
apt install -y apache2

# 2. Activer les modules
echo "[2/9] Activation des modules rewrite et ssl..."
a2enmod rewrite
a2enmod ssl

# 3. Créer le dossier Sites si nécessaire
echo "[3/9] Création du dossier ~/Sites/seedballplanet..."
mkdir -p "$USER_HOME/Sites/seedballplanet"
chown -R $REAL_USER:$REAL_USER "$USER_HOME/Sites"
chmod 755 "$USER_HOME"

# 4. Configuration Virtual Host HTTP
echo "[4/9] Configuration Virtual Host HTTP..."
cat > /etc/apache2/sites-available/seedballplanet.conf << EOF
<VirtualHost *:80>
    ServerName seedballplanet.local
    DocumentRoot $USER_HOME/Sites/seedballplanet

    <Directory $USER_HOME/Sites/seedballplanet>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/seedballplanet-error.log
    CustomLog \${APACHE_LOG_DIR}/seedballplanet-access.log combined
</VirtualHost>
EOF

# 5. Créer le certificat SSL (10 ans)
echo "[5/9] Création du certificat SSL auto-signé (10 ans)..."
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/seedballplanet.key \
  -out /etc/ssl/certs/seedballplanet.crt \
  -subj "/C=CA/ST=Quebec/L=Montreal/O=SeedballPlanet/CN=seedballplanet.local"

# 6. Configuration Virtual Host HTTPS
echo "[6/9] Configuration Virtual Host HTTPS..."
cat > /etc/apache2/sites-available/seedballplanet-ssl.conf << EOF
<VirtualHost *:443>
    ServerName seedballplanet.local
    DocumentRoot $USER_HOME/Sites/seedballplanet

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/seedballplanet.crt
    SSLCertificateKeyFile /etc/ssl/private/seedballplanet.key

    <Directory $USER_HOME/Sites/seedballplanet>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/seedballplanet-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/seedballplanet-ssl-access.log combined
</VirtualHost>
EOF

# 7. Ajouter l'entrée /etc/hosts
echo "[7/9] Ajout de l'entrée dans /etc/hosts..."
if ! grep -q "seedballplanet.local" /etc/hosts; then
    echo "127.0.0.1   seedballplanet.local" >> /etc/hosts
    echo "Entrée ajoutée à /etc/hosts"
else
    echo "Entrée déjà présente dans /etc/hosts"
fi

# 8. Activer les sites
echo "[8/9] Activation des sites..."
a2ensite seedballplanet.conf
a2ensite seedballplanet-ssl.conf

# 9. Redémarrer Apache
echo "[9/9] Redémarrage d'Apache..."
systemctl restart apache2

echo ""
echo "=== Installation terminée! ==="
echo ""
echo "Prochaines étapes:"
echo "1. Clone ton projet: git clone https://github.com/ogbuzz/seedballplanet.git $USER_HOME/Sites/seedballplanet"
echo "2. Teste HTTP: http://seedballplanet.local"
echo "3. Teste HTTPS: https://seedballplanet.local"
echo ""
