#!/usr/bin/env sh

# "00017030023266340908" is my own Google Shared items user ID
# You can find yours by opening your own Google Shared items page.

USER="00017030023266340908"
QUANTITY=100000
FILENAME="google_reader.xml"

echo Downloading the RSS XML feed with Google Reader shared items
curl http://www.google.com/reader/public/atom/user%2F${USER}%2Fstate%2Fcom.google%2Fbroadcast\?r=n\&n=${QUANTITY} > ${FILENAME}

for i in 2006 2007 2008 2009; do
    echo Generating HTML files with the titles of the shared articles in ${i}
    ruby parse.rb ${FILENAME} ${i} > ${i}.html
done
