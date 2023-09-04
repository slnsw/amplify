#!/bin/sh
### BEGIN INIT INFO
# Provides:          amplify_puma
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Runs Amplify server via Puma.
### END INIT INFO

RUNAS=deploy
RUNAS_UID=$(id -u $RUNAS)

APP_DIR="/home/$RUNAS/nsw-state-library-amplify/current"
RVM_BIN="/home/$RUNAS/.rvm/bin/rvm"
RVM_RUBY="ruby-3.0.0"
PUMA_SCRIPT="/home/$RUNAS/nsw-state-library-amplify/shared/puma.rb"
PUMA_STATE="/home/$RUNAS/nsw-state-library-amplify/shared/tmp/pids/puma.state"
SIDEKIQ_SERVICE="sidekiq-staging.service"

start() {
  echo 'Trying to start service…' >&2
  su -c "cd $APP_DIR && $RVM_BIN $RVM_RUBY do bundle exec puma -C $PUMA_SCRIPT --daemon" $RUNAS
  su -c "XDG_RUNTIME_DIR=/run/user/$RUNAS_UID systemctl --user start $SIDEKIQ_SERVICE" $RUNAS
  echo 'Service started' >&2
}

stop() {
  echo 'Stopping service…' >&2
  su -c "cd $APP_DIR && $RVM_BIN $RVM_RUBY do bundle exec pumactl -S $PUMA_STATE -F $PUMA_SCRIPT stop" $RUNAS
  su -c "XDG_RUNTIME_DIR=/run/user/$RUNAS_UID systemctl --user stop $SIDEKIQ_SERVICE" $RUNAS
  echo 'Service stopped' >&2
}

restart() {
  echo 'Trying to restart service…' >&2
  su -c "cd $APP_DIR && $RVM_BIN $RVM_RUBY do bundle exec pumactl -S $PUMA_STATE -F $PUMA_SCRIPT restart" $RUNAS
  su -c "XDG_RUNTIME_DIR=/run/user/$RUNAS_UID systemctl --user stop $SIDEKIQ_SERVICE" $RUNAS
  su -c "XDG_RUNTIME_DIR=/run/user/$RUNAS_UID systemctl --user start $SIDEKIQ_SERVICE" $RUNAS
  echo 'Service started' >&2
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
esac
