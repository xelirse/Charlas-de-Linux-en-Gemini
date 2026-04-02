#!/bin/sh

# apt reinstalar todo menos libc
$(echo apt reinstall $( apt list --installed 2>/dev/null | \
	cat - | \
	sed -E "s/\/(.+)|(L.+)//g" | \
	grep -Ev "^base-files$" | \
	grep -Ev "^libc6$" | \
	tr "\n" " "
))
