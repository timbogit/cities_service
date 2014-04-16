class City < ActiveRecord::Base
  attr_accessible :name, :state, :country, :latitude, :longitude

  geocoded_by :geocode_string

  def geocode_string
    "#{name}_#{state}_#{country}"
  end
end
