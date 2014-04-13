class City < ActiveRecord::Base
  attr_accessible :name, :state, :country, :latitude, :longitude

  geocoded_by :geocode_string
  reverse_geocoded_by :longitude, :latitude

  def geocode_string
    "#{name}_#{state}_#{country}"
  end
end
