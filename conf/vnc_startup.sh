#!/bin/sh

vncserver -kill :1
vncserver -geometry 1920x1080 &> /dev/null
./.novnc/utils/launch.sh --vnc localhost:5901 &> /dev/null 
tail -f /etc/passwd
