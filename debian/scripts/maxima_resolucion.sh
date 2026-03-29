#!/bin/sh

xrandr --output VGA-1 --mode $( xrandr | grep -E "^ +[0-9]+x[0-9]+" | sort -nr -t 'x' -k1,1 -k2,2 | head -n1  | awk '{print $1}' )
