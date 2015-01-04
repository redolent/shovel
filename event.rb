require 'oj'

class Event
  
  attr_accessor :id
  attr_accessor :address 
  attr_accessor :bw_id
  attr_accessor :category
  attr_accessor :cost
  attr_accessor :description
  attr_accessor :title
  attr_accessor :venue
  attr_accessor :date
  attr_accessor :date_raw
  attr_accessor :phone
  attr_accessor :bs_id 
  
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
    @id = 'bw' + @bw_id
  end

  def to_json
    #hash = {}
    #self.instance_variables.each do |var|
    #  hash[var] = self.instance_variable_get var
    #end
    #hash.to_json
    s = Oj::dump self
    s = s.gsub('"^o":"Event",','')
    s
  end

end
