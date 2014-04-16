class City < ActiveRecord::Base
  attr_accessible :name, :state, :country, :latitude, :longitude

  geocoded_by :geocode_string

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :country
  validates_numericality_of :latitude, allow_nil: true
  validates_numericality_of :longitude, allow_nil: true

  def geocode_string
    "#{name}_#{state}_#{country}"
  end
end
