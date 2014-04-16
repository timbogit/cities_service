class Presenters::V1::CityPresenter < ::Presenter

  attr_accessor :city

  def initialize(item)
    @city = item
    super(@city)
  end

  def to_hash(item = city)
    HashWithIndifferentAccess.new(
    {
      id:           city.id,
      name:         city.name,
      state:        city.state,
      country_name: city.country,
      latitude:     city.latitude,
      longitude:    city.longitude,
      path:         city_path(self.class.version_number, city.id)
    })
  end
end
