#!/bin/bash
echo 'cron2:'
export PATH="/home/ubuntu/.rvm/gems/ruby-2.1.0/bin:/home/ubuntu/.rvm/gems/ruby-2.1.0@global/bin:/home/ubuntu/.rvm/rubies/ruby-2.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/ubuntu/.rvm/bin:/home/ubuntu/.rvm/bin:/home/ubuntu/.rvm/bin"
cd "$( dirname "${BASH_SOURCE[0]}" )"
exec ./run.sh
