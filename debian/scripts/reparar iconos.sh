#!/bin/sh

find . -type f -name "*.svg" -exec sed -i 's/ osb:paint="solid"//g' {} +
