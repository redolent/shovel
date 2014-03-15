#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"
dir="`pwd`"

sudo su ubuntu -c "/bin/bash '$dir'"/cron2.sh

