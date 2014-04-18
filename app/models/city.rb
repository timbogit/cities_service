class City < ActiveRecord::Base
  attr_accessible :name, :state, :country, :latitude, :longitude

  geocoded_by :geocode_string

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :country
  validates_numericality_of :latitude, allow_nil: true
  validates_numericality_of :longitude, allow_nil: true

  after_destroy :destroy_remote_tags

  def tags(refresh = false)
    @tags = RemoteTag.find_by_city_ids([id]) if refresh || !@tags
    @tags
  end

  def geocode_string
    "#{name}_#{state}_#{country}"
  end

  private

  def destroy_remote_tags
    RemoteTag.destroy_tags_for_city(id, tags.map(&:name))
  end

end
