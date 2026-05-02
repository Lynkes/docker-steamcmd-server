#!/bin/bash
killpid="$(pidof ProjectZomboid64)"
while true
do
	tail --pid=$killpid -f /dev/null
	pkill -f "tail.*masterLog"
	exit 0
done