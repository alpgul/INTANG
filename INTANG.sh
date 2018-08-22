#!/bin/sh
dir=/opt/INTANG
PID=""
service=INTANG
 get_pid() {
   PID=$$
}

 stop() {
   get_pid
   if [ -z $PID ]; then
      echo "server is not running."
      exit 1
   else
      echo -n "Stopping server.."
      kill -9 $PID
      sleep 1
      echo ".. Done."
   fi
}


 start() {
   get_pid
   if [ $(pidof $service | wc -w) ]; then
      echo  "Starting server..$(dirname "$0")"
      sudo $dir/bin/intangd 10 || echo "intangd not found. Maybe run make first." &
      get_pid
      echo "Done. PID=$PID"
   else
      echo "server is already running, PID=$PID"
   fi
}

 restart() {
   echo  "Restarting server.."
   get_pid
   if [ -z $PID ]; then
      start
   else
      stop
      sleep 5
      start
   fi
}


 status() {
   get_pid
   if [ -z  $PID ]; then
      echo "Server is not running."
      exit 1
   else
      echo "Server is running, PID=$PID"
   fi
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
   status)
      status
   ;;
   *)
      echo "Usage: $0 {start|stop|restart|status}"
esac
