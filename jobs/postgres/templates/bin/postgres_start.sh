#!/bin/bash -e

JOB_DIR=/var/vcap/jobs/postgres
PACKAGE_DIR=/var/vcap/packages/postgres-9.4
PACKAGE_DIR_OLD=/var/vcap/packages/postgres

STORE_DIR=/var/vcap/store
DATA_DIR=$STORE_DIR/postgres-9.4
DATA_DIR_OLD=$STORE_DIR/postgres
DATA_DIR_PREVIOUS=$STORE_DIR/postgres-previous

RUN_DIR=/var/vcap/sys/run/postgres
PIDFILE=$RUN_DIR/postgres.pid

HOST='0.0.0.0'
PORT="<%= p("port") %>"
LD_LIBRARY_PATH=$PACKAGE_DIR/lib:$LD_LIBRARY_PATH

if [ -d $DATA_DIR -a -f $STORE_DIR/FLAG_POSTGRES_UPGRADE ]; then
  echo "FAIL: DB upgrade stopped in the middle, manual intervention required, quitting..."
  exit 1
fi


# Ensure that default postgres bin_dir of the postgres plugin is able to locate the bin_dir
if [ ! -d $PACKAGE_DIR_OLD ]; then
  ln -s $PACKAGE_DIR $PACKAGE_DIR_OLD
fi

sysctl -w "kernel.shmmax=284934144"

if [ ! -d $STORE_DIR ]; then
  echo "ERROR: storage directory doesn't exist"
  echo "Please add persistent disk to this job"
  exit 1
fi

if [ ! -d $DATA_DIR -o ! -f $DATA_DIR/postgresql.conf ]; then
  mkdir -p $DATA_DIR
  chown vcap:vcap $DATA_DIR

  # initdb creates data directories
  su - vcap -c "$PACKAGE_DIR/bin/initdb -E utf8 --locale en_US.UTF-8 -D $DATA_DIR"

  mkdir -p $DATA_DIR/pg_log
  chown vcap:vcap $DATA_DIR/pg_log
fi

if [ -d $DATA_DIR_OLD -a -f $DATA_DIR_OLD/postgresql.conf ]; then

  if [ -d $DATA_DIR_PREVIOUS ]; then
    rm -rf $DATA_DIR_PREVIOUS
  fi

  touch $STORE_DIR/FLAG_POSTGRES_UPGRADE

  # Prevent upgrade from overwriting PIDFILE with new process during upgrade
  chown root:root $PIDFILE

  su - vcap -c "$PACKAGE_DIR/bin/pg_upgrade \
    --old-datadir $DATA_DIR_OLD \
    --new-datadir $DATA_DIR \
    --old-bindir $PACKAGE_DIR_OLD/bin \
    --new-bindir $PACKAGE_DIR/bin"

  chown vcap:vcap $PIDFILE

  rm -f $STORE_DIR/FLAG_POSTGRES_UPGRADE
  mv $DATA_DIR_OLD $DATA_DIR_PREVIOUS
fi

cp $JOB_DIR/config/{postgresql,pg_hba}.conf $DATA_DIR
chown vcap:vcap $DATA_DIR/{postgresql,pg_hba}.conf

echo "Starting PostgreSQL: "
su - vcap -c "$PACKAGE_DIR/bin/pg_ctl -o \"-h $HOST -p $PORT\" \
              -w start -D $DATA_DIR -l \"$DATA_DIR/pg_log/startup.log\""

echo "PostgreSQL started successfully"

echo "Creating roles..."
<% p("roles", []).each do |role| %>
  echo "Trying to create role <%= role["name"] %>..."
  set +e
  # TODO remove unused roles automatically
  # Default permissions are: nosuperuser nologin inherit nocreatedb.
  # Will fail if role already exists, which is OK
  $PACKAGE_DIR/bin/psql -U vcap -p $PORT -d postgres \
                        -c "CREATE ROLE \"<%= role["name"] %>\""
  set -e

  echo "Setting password for role <%= role["name"] %>..."
  $PACKAGE_DIR/bin/psql -U vcap -p $PORT -d postgres \
                        -c "ALTER ROLE \"<%= role["name"] %>\" \
                            WITH LOGIN PASSWORD '<%= role["password"] %>'"

  <% if role["permissions"] %>
    echo "Adding permissions <%= role["permissions"].join(' ') %> for role <%= role["name"] %>..."
    $PACKAGE_DIR/bin/psql -U vcap -p $PORT -d postgres \
                      -c "ALTER ROLE \"<%= role["name"] %>\" \
                          WITH <%= role["permissions"].join(' ') %>"
  <% end %>
<% end %>

echo "Creating .."
<% p("databases", []).each do |database| %>
  echo "Trying to create database <%= database["name"] %>..."
  set +e
  su - vcap -c "$PACKAGE_DIR/bin/createdb \"<%= database["name"] %>\" -p $PORT"
  set -e

  <% if database["citext"] %>
    echo "Trying to install citext..."
    set +e
    $PACKAGE_DIR/bin/psql -U vcap -p $PORT \
                          -d "<%= database["name"] %>" \
                          -c "CREATE EXTENSION citext"
    $PACKAGE_DIR/bin/psql -U vcap -p $PORT \
                          -d "<%= database["name"] %>" \
                          -c "CREATE EXTENSION citext FROM UNPACKAGED"
    set -e
  <% end %>

  <% if database["run_on_every_startup"] %>
    <% database["run_on_every_startup"].each do |query| %>
      $PACKAGE_DIR/bin/psql -U vcap -p $PORT \
                            -d "<%= database["name"] %>" \
                            -c "<%= query %>"
    <% end %>
  <% end %>
<% end %>
