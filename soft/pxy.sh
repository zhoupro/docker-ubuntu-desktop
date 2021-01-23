#!/bin/bash
export http_proxy=http://localhost:39571
export https_proxy=http://localhost:39571
starttime=$(date +%s)
#执行程序
"$@"
endtime=$(date +%s)
echo "use time： "$((endtime-starttime))"s"
unset http_proxy
unset https_proxy
