#!/bin/bash
whoami
set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"
ruby="/home/ubuntu/.rvm/rubies/ruby-2.1.0/bin/ruby"

#
# Runs the crawler
#


mkdir -p tmp
tempfile="`pwd`/tmp/run-`date +%Y%m%d`.json"
> "$tempfile"


cd shovel
echo Running... 1>&2
$ruby run.rb                                       >> "$tempfile"
sed -i -E 's%"\^o":"Event",?%%g'                      "$tempfile" 
sed -i -E 's%"bw_id":"([^"]*)"(,?)%"id":"bw\1"\2%g'   "$tempfile" # convert id:bw123
echo `wc -c < "$tempfile"` characters

echo Importing "$tempfile" ... 1>&2
cd ..
./to-solr.sh "$tempfile"

