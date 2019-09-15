## osd_cat_pomodoro
A minimal pomodoro timer using osd_cat.

![](/example.png)

By default, the timer runs for 25 minutes (in red) followed by a large "TAKE A BREAK" message. After that, the break timer runs for 5 minutes (in green).

After the break is done, a popup (using zenity) asks "Again?" with a yes or no. Yes starts the script again.

The PID is displayed below the counter so that the timer can be ended. Since I generally run it in the background through a hotkey, there's nowhere to ctrl-c out of.

To exit the script...
    
    kill -9 <pid>

## options:

-m <number>:
    sets the number of minutes that the timer should run for.

-s <number>: 
    the same for seconds

-b <number>:
    the length of the break

## setup:
requires xosd-bin and zenity

        apt-get install xosd-bin zenity

On my computer, I'm using xbindkeys to handle keyboard shortcuts. Add the following to your .xbindkeysrc to  winkey + backspace, changing the directory to where you like to keep your scripts.

        #pomodoro hotkey
        "sleep .1; bash /home/aaron/scripts/pomodoro.sh &"
        Mod4 + BackSpace

When I'm trying to figure out the keycodes for a new hotkey, I've found 'xbindkeys -mk' useful.


