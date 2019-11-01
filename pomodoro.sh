#!/bin/bash

#define default values:
MINUTES=25
SECONDS=0
WILL_BREAK=1

#handle arguments:
while getopts ":m:s:b:" opt; do
  case $opt in
    m)
      echo "-m was triggered, Parameter: $OPTARG" >&2
      MINUTES=$OPTARG
      ;;
    s)
      echo "-s was triggered, Parameter: $OPTARG" >&2
      SECONDS=$OPTARG
      ;;
    b)
      echo "-b was triggered, Parameter: $OPTARG" >&2
      WILL_BREAK=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

function finish {
    killall osd_cat
}
trap finish EXIT

function osd_cat_br(){
    #writes to the top right of the screen.
    #The second line includes <pomodoro minutes>/<break minutes> followed by
    #the PID below the time readout for easily killing the process.
    #osd_cat needs something piped to it. osd_cat accepts raw text from cat
    color=$1
    while read data; do
        echo "$data" | osd_cat --pos=top --align=right --font=-*-helvetica-bold-r-*-*-60-*-*-*-*-*-*-* --offset=-4 -i -10 -d 1 -O 2 -c $color &
        echo $MINUTES\ /\ $BREAK\ \|\ PID:$$ | osd_cat --pos=top --align=right --font=-*-helvetica-bold-r-*-*-12-*-*-*-*-*-*-* --offset=50 -i -6 -d 1 -O 2 -c $color &
    done 
}

function print_countdown(){
        color=$3
        if (($1 < 10)) && (($2 < 10))
        then
        echo 0$1:0$2 | osd_cat_br $color
        elif (($1 < 10))
        then
        echo 0$1:$2 | osd_cat_br $color
        elif (($2 < 10))
        then
        echo $1:0$2 | osd_cat_br $color
        else 
        echo $1:$2 | osd_cat_br $color
        fi
        sleep 1
}

#Break duration is a fifth the length of the pomodoro interval.
BREAK=$(expr $MINUTES / 5)
BREAKSUBONE=$(expr $BREAK - 1)

echo BEGIN! | osd_cat --pos=middle --align=center --color=GREEN --font=-*-helvetica-bold-r-*-*-100-*-*-*-*-*-*-* --outline=4 --offset=-100 -d 2 &
print_countdown $MINUTES 0 red
echo "Starting timer for $MINUTES minutes followed by a $BREAK minute break."
for i in `seq 0 $(($MINUTES - 1))`;
do
        for j in `seq 0 59`
        do
            mins=$(expr $(($MINUTES - 1)) - $i)
            secs=$(expr 59 - $j)
            print_countdown $mins $secs red
        done
done    
#flash TAKE A BREAK five times:
for k in `seq 1 5`;
do
        echo TAKE A BREAK. | osd_cat --pos=middle --align=center --color=green --font=-*-helvetica-bold-r-*-*-100-*-*-*-*-*-*-* --outline=4 --offset=-100 -d 1 &
        sleep 2
done

#start the countdown timer:
print_countdown $BREAK 0 green
for l in `seq 0 $BREAKSUBONE`
do
    for m in `seq 0 59`
    do
        mins=$(expr $BREAKSUBONE - $l)
        secs=$(expr 59 - $m)
        print_countdown $mins $secs green
    done
done

if [ $WILL_BREAK -eq 1 ];
    then
    echo AGAIN? | osd_cat --pos=middle --align=center --color=red --font=-*-helvetica-bold-r-*-*-100-*-*-*-*-*-*-* --outline=4 --offset=-100 -d 999 &
    if zenity --question --text="Again?";
        then
        killall osd_cat
        ~/scripts/pomodoro.sh -m $MINUTES -s $SECONDS -b $WILL_BREAK & 
        else
        killall osd_cat
        exit
    fi
fi
