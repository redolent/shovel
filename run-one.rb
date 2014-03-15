require 'oj'
require './boise_weekly.rb'

alldata = []
data  =  Shovel::BoiseWeekly.scrape  when: 'next_week', verbose: true, param: '&page=1'
alldata += data
print  Oj::dump  alldata
print  "\n"

