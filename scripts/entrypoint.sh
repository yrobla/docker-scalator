#!/bin/bash
set -e

# error if the env vars are not present
if [ -z "$SCALATOR_PRIVATE_KEY" ] || [ -z "$SCALATOR_PUBLIC_KEY" ]  ||
   [ -z "$RABBIT_HOST" ] || [ -z "$RABBIT_USER" ] || [ -z "$RABBIT_PASS" ] ||
   [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_USER" ] ||
   [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_PASS" ] ||
   [ -z "$DIGITALOCEAN_PROVIDER_TOKEN" ] ||
   [ -z "$DIGITALOCEAN_PROVIDER_VERSION" ] ||
   [ -z "$DIGITALOCEAN_PROVIDER_SIZE" ]; then
    echo "Error: you must provide all the mandatory env vars"
    exit 1
fi

# add pubkey and privkey that shoud be passed by env vars
if [ ! -d "/root/.ssh" ]; then
    mkdir /root/.ssh
fi
chmod 755 /root/.ssh
echo "$SCALATOR_PRIVATE_KEY" > /root/.ssh/id_rsa

# send the key with newlines, then they are replaced infile
sed -i 's/\\n/\n/g' /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "$SCALATOR_PUBLIC_KEY"  > /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa.pub

# replace in templates
/bin/sed -i "s#RABBIT_HOST#$RABBIT_HOST#g" /etc/scalator/scalator.yaml
if [ -z "$RABBIT_PORT" ]; then
    RABBIT_PORT=5672
fi
/bin/sed -i "s#RABBIT_PORT#$RABBIT_PORT#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#RABBIT_USER#$RABBIT_USER#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#RABBIT_PASS#$RABBIT_PASS#g" /etc/scalator/scalator.yaml
if [ -z "$RABBIT_VHOST" ]; then
    RABBIT_VHOST='%2F'
fi
/bin/sed -i "s#RABBIT_VHOST#$RABBIT_VHOST#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#MYSQL_USER#$MYSQL_USER#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#MYSQL_PASS#$MYSQL_PASS#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#MYSQL_HOST#$MYSQL_HOST#g" /etc/scalator/scalator.yaml
if [ -z "$MYSQL_PORT" ]; then
    MYSQL_PORT=3306
fi
/bin/sed -i "s#MYSQL_PORT#$MYSQL_PORT#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#MYSQL_DATABASE#$MYSQL_DATABASE#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#DIGITALOCEAN_PROVIDER_TOKEN#$DIGITALOCEAN_PROVIDER_TOKEN#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#DIGITALOCEAN_PROVIDER_VERSION#$DIGITALOCEAN_PROVIDER_VERSION#g" /etc/scalator/scalator.yaml
/bin/sed -i "s#DIGITALOCEAN_PROVIDER_SIZE#$DIGITALOCEAN_PROVIDER_SIZE#g" /etc/scalator/scalator.yaml

if [ -z "$BOOT_TIMEOUT" ]; then
    BOOT_TIMEOUT=3600
fi
/bin/sed -i "s#BOOT_TIMEOUT#$BOOT_TIMEOUT#g" /etc/scalator/scalator.yaml
if [ -z "$LAUNCH_TIMEOUT" ]; then
    LAUNCH_TIMEOUT=3600
fi
/bin/sed -i "s#LAUNCH_TIMEOUT#$LAUNCH_TIMEOUT#g" /etc/scalator/scalator.yaml
if [ -z "$MESSAGES_PER_NODE" ]; then
    MESSAGES_PER_NODE=30
fi
/bin/sed -i "s#MESSAGES_PER_NODE#$MESSAGES_PER_NODE#g" /etc/scalator/scalator.yaml
if [ -z "$MAX_SERVERS" ]; then
    MAX_SERVERS=3
fi
/bin/sed -i "s#MAX_SERVERS#$MAX_SERVERS#g" /etc/scalator/scalator.yaml

# drop database and create again
echo "drop database $MYSQL_DATABASE"
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS --execute="DROP DATABASE IF EXISTS $MYSQL_DATABASE"
echo "create database $MYSQL_DATABASE"
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS --execute="CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"
