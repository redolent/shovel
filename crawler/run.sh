#!/bin/bash
whoami
set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"


source /home/ubuntu/.rvm/environments/ruby-2.1.0



#
# Runs the crawler
#


mkdir -p tmp
tempfile="`pwd`/tmp/run-`date +%Y%m%d`.json"
> "$tempfile"

n2526024="Placerville"
n939892="North Boise"
n939889="Boise Downtown and Fringe"
n2610473="Bench"
n2610472="Broadway Avenue"
n2610471="State Street"
n939890="West Boise"
n939891="Bench"
n1492439="Middleton"
n1480621="Marsing"
n939893="Meridian"
n939885="Southwestern Idaho"
n939884="Eastern Idaho"
n939883="Central Idaho"
n939882="North Idaho"
n939887="East Boise"
n939888="Southeast Boise"
n1014713="Kuna"
n939894="Oregon"
n1014712="Eagle"
n1014714="Caldwell"
n1014715="Nampa"
n1014716="Star"
n1014717="Emmett"
n1014718="Garden City"
n1035018="South Boise"
n940625="Greater Boise Area"


neighborhoods="
	939889
	939892
	2610473
	2610472
	2610471
	939891
	1014718
	"

cd shovel

for id in $neighborhoods
do
	name=$( eval echo \$n${id} )
	echo '# '$id $name
	echo '# 'Importing neighborhood \'$name\'... 1>&2
	tempfile="$( readlink -e "run-temp-$name.json" )"
	ruby run.rb $id       > "$tempfile"
	sed -i -E 's%"\^o":"Event",?%%g'      "$tempfile" 
	sed -i -E 's%"bw_id":"[0-9]*",?%%g'   "$tempfile"
	sed -i -E 's%"bw_id":"([^"]*)"(,?)%"id":"bw\1"\2%g'   "$tempfile" # convert id:bw123
	echo `wc -c < "$tempfile"` characters


	echo Importing "$tempfile" ... 1>&2
	(
	cd ..
	./to-solr.sh "$tempfile"
	)
done


