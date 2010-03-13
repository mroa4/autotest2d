#!/bin/bash

MATCHES=3
ROUNDS=100

server() {
	ulimit -t 180
	rcssserver $*
}

match() {
    SERVER_HOST=localhost

    if [ ! -z $1 ]; then
        SERVER_HOST=$1
    fi

	RESULT="result_$SERVER_HOST"
	LOGDIR="log_$SERVER_HOST"

	OPTIONS=""
	OPTIONS="$OPTIONS -server::game_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::text_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::team_l_start=\"./start_left $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::team_r_start=\"./start_right $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::nr_normal_halfs=2 -server::nr_extra_halfs=0"
	OPTIONS="$OPTIONS -server::penalty_shoot_outs=false -server::auto_mode=on"
	OPTIONS="$OPTIONS -server::game_logging=true -server::text_logging=false"

    if [ $MATCHES -gt 1 ]; then
        OPTIONS="$OPTIONS -server::host=\"$SERVER_HOST\""
    fi

	mkdir $LOGDIR
	exec > $RESULT

	for i in `seq 1 $ROUNDS`; do
		server $OPTIONS
		sleep 5
	done
}

autotest() {
	./clear.sh

	TOTAL_ROUNDS=`expr $MATCHES '*' $ROUNDS`
	echo $TOTAL_ROUNDS > total_rounds

    if [ $MATCHES -gt 1 ]; then
        export LANG=POSIX
        IP_PATTERN='192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
        SERVER_HOSTS=(`ifconfig | grep -o "inet addr:$IP_PATTERN" | grep -o "$IP_PATTERN"`)

        i=0
        while [ $i -lt $MATCHES ] && [ $i -lt ${#SERVER_HOSTS[@]} ]; do
            match ${SERVER_HOSTS[$i]} &
            i=`expr $i + 1`
            sleep 30
        done
    else
        match &
    fi
}

if [ $# -gt 0 ]; then
	autotest
else
	$0 $# &
fi

