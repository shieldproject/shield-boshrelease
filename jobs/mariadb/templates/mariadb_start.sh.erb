JOB_DIR=/var/vcap/jobs/mariadb
PACKAGE_DIR=/var/vcap/packages/mariadb

STORE_DIR=/var/vcap/store
DATA_DIR=$STORE_DIR/mariadb

SERVER=$PACKAGE_DIR/support-files/mysql.server
RUN_DIR=/var/vcap/sys/run/mariadb
PIDFILE=$RUN_DIR/mariadb.pid

PORT=<%= p('databases.port') %>

if [ ! -d $STORE_DIR ]; then
  echo "ERROR: storage directory doesn't exist"
  echo "Please add persistent disk to this job"
  exit 1
fi


if [ ! -d $DATA_DIR ]; then
  mkdir -p $DATA_DIR
  cp $JOB_DIR/config/my.cnf ~vcap/.my.cnf
  chown vcap:vcap $DATA_DIR

  su - vcap -c "$PACKAGE_DIR/scripts/mysql_install_db --user vcap --datadir=$DATA_DIR --basedir=$PACKAGE_DIR"
fi

echo "Starting MariaDB: "
su - vcap -c "$SERVER start --datadir=$DATA_DIR --basedir=$PACKAGE_DIR --pid-file=$PIDFILE"

su - vcap -c "echo \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\" | $PACKAGE_DIR/bin/mysql --port $PORT -u root"

echo "Creating roles..."
<% p("databases.roles", []).each do |role| %>
  echo "Trying to create role <%= role["name"] %>..."
  set +e
  su - vcap -c "echo \"GRANT ALL PRIVILEGES ON *.* TO '<%= role["name"] %>'@'%' IDENTIFIED BY '<%= role["password"] %>'; FLUSH PRIVILEGES;\" | $PACKAGE_DIR/bin/mysql --port $PORT -u root"
  set -e
<% end %>

echo "Creating databases..."
<% p("databases.databases", []).each do |database| %>
  echo "Trying to create database <%= database["name"] %>..."
  set +e
  su - vcap -c "$PACKAGE_DIR/bin/mysqladmin --port $PORT -u root create <%= database["name"] %>"
  set -e
<% end %>

echo "MariaDB started successfully"
