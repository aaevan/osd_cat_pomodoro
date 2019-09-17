 #!/bin/bash

MINUTES=25
SECONDS=0
WILL_BREAK=1

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
    #writes to the bottom right of the screen and includes the PID.
    #osd_cat needs something piped to it-- we can't pipe directly to a function
    #so first the data needs to be read.
    color=$1
    echo $color
    while read data; do
        echo "$data" | osd_cat --pos=top --align=right --font=-*-helvetica-bold-r-*-*-60-*-*-*-*-*-*-* --offset=-4 -i -10 -d 1 -O 2 -c $color &
        echo PID:$$ | osd_cat --pos=top --align=right --font=-*-helvetica-bold-r-*-*-12-*-*-*-*-*-*-* --offset=50 -i -6 -d 1 -O 2 -c $color &
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

print_countdown $MINUTES 0 red
for i in `seq 0 $(($MINUTES - 1))`;
do
        for j in `seq 0 59`
        do
            mins=$(expr $(($MINUTES - 1)) - $i)
            secs=$(expr 59 - $j)
            print_countdown $mins $secs red
        done
done    

for k in `seq 1 5`;
do
        echo TAKE A BREAK. | osd_cat --pos=middle --align=center --color=green --font=-*-helvetica-bold-r-*-*-100-*-*-*-*-*-*-* --outline=4 --offset=-100 -d 1 &
        sleep 2
done

#Break is a fifth the length of the pomodoro interval.
BREAK=$(expr $MINUTES / 5)
BREAKSUBONE=$(expr $BREAK - 1)

print_countdown $BREAK 0 green
for l in `seq 0 $BREAKSUBONE`
do
    for m in `seq 0 59`
    do
        mins=$(expr 4 - $l)
        secs=$(expr 59 - $m)
        print_countdown $mins $secs green
    done
done

if [ $WILL_BREAK -eq 1 ];
    then
    if zenity --question --text="Again?";
        then
        ~/scripts/pomodoro.sh -m $minutes -s $seconds & 
        else
        exit
    fi
fi



