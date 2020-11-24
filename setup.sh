#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo privilages." 
   exit 1
fi

source env.sh

if ! command -v psql &> /dev/null
then
    echo "PostgreSQL does not exist. Installing package..."
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql
else
    echo "PostgreSQL detected."
fi

if ! id postgres &> /dev/null
then
    echo "postgres user does not exist."
    exit 1
fi

sudo su - postgres <<EOF
    psql -c "DROP OWNED BY $SUPER_USER CASCADE"
    psql -c "DROP DATABASE IF EXISTS $SUPER_USER"
    psql -c "DROP ROLE IF EXISTS $SUPER_USER"
    psql -c "CREATE USER $SUPER_USER WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION PASSWORD '$SUPER_PASSWORD'"
    psql -c "CREATE DATABASE $SUPER_USER"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE $SUPER_USER TO $SUPER_USER"
EOF

if ! psql -c "SELECT * FROM pg_roles" "$SUPER_AUTH" > /dev/null
then
    echo "PostgreSQL client authentication might default to 'peer' authentication instead of 'password' or 'md5'."
    echo "It might be necessary for you, the user, to go into the config file and edit the settings manually."
    echo ">>> cd /etc/postgresql/../main"
    echo ">>> cat pg_hba.conf"
else
    echo "Success! PostgreSQL super user created: $SUPER_USER"
fi

psql -c "DROP OWNED BY $STUDENT_USER CASCADE" "$SUPER_AUTH"
psql -c "DROP DATABASE IF EXISTS $STUDENT_USER" "$SUPER_AUTH"
psql -c "DROP ROLE IF EXISTS $STUDENT_USER" "$SUPER_AUTH"
psql -c "CREATE USER $STUDENT_USER PASSWORD '$STUDENT_PASSWORD'" "$SUPER_AUTH"
psql -c "CREATE DATABASE $STUDENT_USER OWNER $STUDENT_USER" "$SUPER_AUTH"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $STUDENT_USER TO $STUDENT_USER" "$SUPER_AUTH"

if ! psql -c "SELECT * FROM pg_roles" "$STUDENT_AUTH" > /dev/null
then
    echo "PostgreSQL client authentication might default to 'peer' authentication instead of 'password' or 'md5'."
    echo "It might be necessary for you, the user, to go into the config file and edit the settings manually."
    echo ">>> cd /etc/postgresql/../main"
    echo ">>> cat pg_hba.conf"
else
    echo "Success! PostgreSQL student user created: $STUDENT_USER"
fi
