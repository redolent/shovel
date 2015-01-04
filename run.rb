require 'oj'
require './boise_weekly.rb'

alldata = []
1.upto 100 do |i|
  data  =  Shovel::BoiseWeekly.scrape  when: 'next_month', verbose: true, param: '&page=' + i.to_s, neighborhood:ARGV[0]
  alldata += data
  break if data.empty?
end
print  Oj::dump  alldata
print  "\n"

