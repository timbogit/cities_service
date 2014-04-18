class Presenters::V1::CityPresenter < ::Presenter

  attr_accessor :city

  def initialize(city)
    @city = city
    super(@city)
  end

  def to_hash(ct = city)
    HashWithIndifferentAccess.new(
    {
      id:           ct.id,
      name:         ct.name,
      state:        ct.state,
      country_name: ct.country,
      latitude:     ct.latitude,
      longitude:    ct.longitude,
      path:         city_path(self.class.version_number, ct.id),
      tags:         ct.tags.map(&:name)
    })
  end
end
