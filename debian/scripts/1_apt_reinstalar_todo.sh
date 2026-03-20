#!/bin/sh

$(echo apt reinstall $( apt list --installed 2>/dev/null | cat - | sed -E "s/\/(.+)|(L.+)//g" | tr "\n" " " ))