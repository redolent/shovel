#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"
dir="`pwd`"

if [ "`whoami`" != "ubuntu" ]; then
	su ubuntu
fi
exec "$dir"/run.sh
