require 'nokogiri'
require 'mechanize'
require 'open-uri'

require './categories'
require './event'

module Shovel
  class BoiseWeekly
    
    @base_url = 'http://www.boiseweekly.com/boise/EventSearch?narrowByDate='
    
    def self.scrape options = {}
      events = []
      sub_url = case options[:when]
                when 'today' then 'Today'
                when 'next_week' then 'Next%207%20Days' 
                when 'next_month' then 'Next%2030%20Days' 
                when 'this_weekend' then 'This%20Weekend'
                else
                       print "ERROR "
                       #print options
                       print options[:when]
                       print " is not set\n"
                       exit
                end
      
      $stderr.puts "Period: " + sub_url + "\n"  if options[:verbose]
      url = @base_url + sub_url
      # url << '&neighborhood=939889'
      url << '&neighborhood=' << options[:neighborhood]
      url << options[:param] if options[:param]
      
      $stderr.puts "Loading " + url + "\n"  if options[:verbose]
      page = Nokogiri::HTML open url
      page.css('.EventListing').each do |listing|
        
        event_params = {}
        listing.css('h3').css('a').each do |event_href|
          next unless event_href['href'].include? 'Event?oid='
          event_params[:title]        =  event_href.text.gsub(/\s+/, ' ').strip
          event_params[:description]  =  strip_description  listing.clone
          event_params[:category]     =  strip_category     listing.clone
          event_params[:address]      =  strip_address      listing.clone
          event_params[:venue]        =  strip_venue        listing.clone
          #event_params[:phone]        =  strip_phone       listing.clone
          event_params[:bw_id]        =  strip_oid event_href
          event_params[:cost]         =  strip_cost         listing.clone
          event_params[:date_raw]     =  strip_date         listing.clone
          event_params[:date]         =  parse_date event_params[:date_raw]
        end
        
        unless event_params.keys.empty?
          events << Event.new(event_params)
        end
      end
      
      events
    end
    
    def self.strip_oid event_href
      return if event_href.nil?
      event_href['href'].split('?oid=')[1].gsub(/\s+/, ' ').strip
    end
    
    def self.strip_date listing
      return if listing.nil?
      listing = listing.clone()
      
      # Here, since the date isn't actually in any type of container,
      # we must grab all the other textual information from the parent
      # div and remove it, thus leaving us with our desired date string.
      listing.css('h3').remove
      listing.css('.eventCategories').remove
      listing.css('.descripText').remove
      listing.css('script').remove
      #header_stuff_we_dont_want       =  listing.css('h3').text
      #category_stuff_we_dont_want     =  listing.css('.eventCategories').text
      #description_stuff_we_dont_want  =  listing.css('.descripText').text
      #phone_stuff_we_dont_want        =  /[()0-9. \-]{7,}/
      
      all_stuff = listing.text
      ##all_stuff.strip! # this has to be before any calls to slice
      lines = all_stuff.lines.select do |line|
          next false if line.strip.empty?
          next true  if line.include? "p.m."
          next true  if line.include? "a.m."
          next true  if line.include? "Mon.,"
          next true  if line.include? "Tue.,"
          next true  if line.include? "Wed.,"
          next true  if line.include? "Thu.,"
          next true  if line.include? "Fri.,"
          next true  if line.include? "Sat.,"
          next true  if line.include? "Sun.,"
          next true  if line.match    /[()0-9.\s\-]{7,}.*/m
          next false
      end

      #all_stuff.slice!  header_stuff_we_dont_want
      #all_stuff.slice!  category_stuff_we_dont_want
      #all_stuff.slice!  description_stuff_we_dont_want
      #all_stuff.slice!  phone_stuff_we_dont_want

      final = lines.first.strip
      final.slice!   /[()0-9.\s\-]{7,}.*/m
      final
      ##all_stuff.slice!   /[()0-9.\s\-]{7,}.*/m
      ##all_stuff
    end

    def self.parse_date date_str
      date_str = date_str.clone

      date_str.gsub! ".",      ""  # delete dots: p.m --> pm  
      date_str.gsub! /-[^ ]*/, ""  # delete periods: 3-5 pm --> 3 pm

      # Change 9 pm to 9:0 pm without affecting 9:15 pm
      date_str.gsub! /([0-9])(:([0-9]+))?( [ap]m)/, "\\1:0\\3\\4"
      date_str.gsub! /:0([0-9]+)/, ":\\1"

      begin
        if date_str.match /[A-Za-z]+,? [0-9:]+ [ap]m/
          # e.g., "Sundays, 1-1:30 p.m."
          date_str.sub! /^([A-Za-z]+)+s,? /, "\\1, "
          time = DateTime.strptime(date_str, "%a, %l:%M %P").strftime("%s")
        else
          date_str.sub! /^([A-Za-z]{0,3})[a-z]*,? /, "\\1, "
          date_str.sub! /, *([A-Za-z]{0,3})[a-z]*/, ", \\1"
          time = DateTime.strptime(date_str, "%a, %b %e, %l:%M %P").strftime("%s")
        end
      rescue
        time = ""
      end
      time
    end
    
    def self.strip_venue listing
      return if listing.nil? or listing.search('.locationLabel').empty?
      listing.search('.locationLabel').first.text.strip
    end
    
    def self.strip_category listing
      return if listing.nil? or listing.search('.eventCategories').empty?
      category =  listing.search('.eventCategories').first.text.strip
      #Categories::BoiseWeekly.parse_from_string category
    end
    
    def self.strip_address listing
      return if listing.nil?
      
      address = listing.search('.descripTxt').first
      address.search('.//span').remove
      #address.text #.split(' ').first # << " Idaho"
      address = address.text
      address.gsub! /\s+/, " "
      address.gsub! "(map)", " "
      address.strip!
    end
    
    def self.strip_phone listing
      return if listing.nil?
      
      listing.css('.listingLocation').text.split(')').second
        .gsub(/\s+/, ' ').gsub(listing.css('.listingLocation').css('.locationRegion').text, '')
        .strip.split(' ').pop
    end
    
    def self.strip_description listing
      return if listing.nil?
      desc = listing.css('.descripTxt')[1]
      return if desc.nil?
      x    = desc.text
      return if x.nil?
      text = x.gsub(/\s+/, ' ').strip.split(' ')
      text.pop  # Remove price.
      text.join(' ')
    end
    
    def self.strip_cost listing
      return if listing.nil?
      # Get the last word in the description
      desc = listing.css('.descripTxt')[1]
      return if desc.nil?
      desc.text.gsub(/\s+/, ' ').strip.split(' ').pop.downcase
    end
  end
end
