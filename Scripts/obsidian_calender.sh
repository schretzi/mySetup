#!/bin/bash

to_date=`date -j -f "%Y-%m-%d" $title "+%B %d, %Y"`
events_string="eventsFrom:\"$to_date\" to:\"$to_date\""

base_cmd='/opt/homebrew/bin/icalBuddy -nrd -npn -nc -ps "/: /" -iep "datetime,title" -po "datetime, title" -b "\n\n### " -df "" -tf "%H%M" '

if [ $cal = "Rewe" ]; then
    cal_cmd='-ic "Calendar" -f '
else
    cal_cmd='-ec "Calendar" -f '
fi
full_cmd="$base_cmd $cal_cmd $events_string"
eval "$full_cmd | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g'";
