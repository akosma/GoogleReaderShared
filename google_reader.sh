#!/usr/bin/env sh

# "00017030023266340908" is my own Google Shared items user ID
# You can find yours by opening your own Google Shared items page.

curl http://www.google.com/reader/public/atom/user%2F00017030023266340908%2Fstate%2Fcom.google%2Fbroadcast\?r=n\&n=100000 > google_reader.xml

ruby parse.rb google_reader.xml 2006 > 2006.html
ruby parse.rb google_reader.xml 2007 > 2007.html
ruby parse.rb google_reader.xml 2008 > 2008.html
ruby parse.rb google_reader.xml 2009 > 2009.html
