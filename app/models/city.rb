class City < ActiveRecord::Base
  attr_accessible :name, :state, :country, :latitude, :longitude

  geocoded_by: :name, :state, :country
  reverse_geocoded_by: :longitude, :latitude
end
