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
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -t raw -F 
iptables -t raw -X
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
#iptables -t nat -I PREROUTING -p icmp -j DROP
iptables -t raw -I PREROUTING -p tcp -m tcp --sport 80 --tcp-flags RST RST -j NFQUEUE --queue-num 1
iptables -t raw -I PREROUTING -p tcp -m tcp --sport 80 --tcp-flags SYN,ACK SYN,ACK -j NFQUEUE --queue-num 1
iptables -t mangle -I PREROUTING -p tcp -m tcp --sport 80 --tcp-flags SYN,RST,ACK ACK -m u32 --u32 "0x0>>0x16&0x3c@0xc>>0x1a&0x3c@0x0=0x48545450" -j NFQUEUE --queue-num 1
iptables -t raw -I PREROUTING -p tcp -m tcp --sport 443 --tcp-flags RST RST -j NFQUEUE --queue-num 1
iptables -t raw -I PREROUTING -p tcp -m tcp --sport 443 --tcp-flags SYN,ACK SYN,ACK -j NFQUEUE --queue-num 1
iptables -t mangle -I PREROUTING -p tcp -m tcp --sport 443 --tcp-flags SYN,RST,ACK ACK -m u32 --u32 "0x0>>0x16&0x3c@0xc>>0x1a&0x3c@0x0&0xffff0000=0x16030000" -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 80 --tcp-flags SYN,ACK SYN -m mark ! --mark 0x9 -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 80 --tcp-flags SYN,RST,ACK ACK -m mark ! --mark 0x9 -m length --length 0:80 -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 80 --tcp-flags SYN,RST,ACK ACK -m mark ! --mark 0x9 -m u32 --u32 "0x0>>0x16&0x3c@0xc>>0x1a&0x3c@0x0=0x47455420" -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 80 --tcp-flags SYN,RST,ACK ACK -m mark ! --mark 0x9 -m u32 --u32 "0x0>>0x16&0x3c@0xc>>0x1a&0x3c@0x0=0x504f5354" -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 443 --tcp-flags SYN,ACK SYN -m mark ! --mark 0x9 -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 443 --tcp-flags SYN,RST,ACK ACK -m mark ! --mark 0x9 -m length --length 0:80 -j NFQUEUE --queue-num 1
iptables -t mangle -I POSTROUTING  -p tcp -m tcp --dport 443 --tcp-flags SYN,RST,ACK ACK -m mark ! --mark 0x9 -m u32 --u32 "0x0>>0x16&0x3c@0xc>>0x1a&0x3c@0x0&0xffff0000=0x16030000" -j NFQUEUE --queue-num 1
      echo "Done. PID=$PID"
      sleep 3
iptables -F

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
