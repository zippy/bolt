#!/bin/sh

README=`pwd`/README

rm -rf doc/rdoc
rdoc --op doc/rdoc -A cattr_accessor --all -N \
    --title 'Bolt Documentation' \
    --main README README LICENSE `find . -name \*.rb`