class Presenters::V1::CityPresenter < ::Presenter

  attr_accessor :city

  def initialize(item)
    @city = item
    super(@city)
  end

  def to_hash(item = city)
    HashWithIndifferentAccess.new(
    {
      name:         city.name,
      state:        city.state,
      country_name: city.country,
      latitude:     city.latitude,
      longitude:    city.longitude,
      path:         city_path(self.class.version_number, city.name)
    })
  end
end
