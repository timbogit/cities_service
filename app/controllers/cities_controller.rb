class CitiesController < ApplicationController
  before_action :find_city, except: [:index, :create, :in_country]
  # Show a single city
  # Example:
  #  `curl -v -H "Content-type: application/json" 'http://localhost:3000/api/v1/cities/1.json'
  def show
    Rails.logger.debug "City with id #{@city.id} is #{@city.id}"

    render_if_stale(@city, last_modified: @city.updated_at.utc, etag: @city) do |city_presenter|
      city_presenter.hash
    end
    # explicitly setting the Cache-Control response header to public and max-age, to make the response cachable by proxy caches
    expires_in caching_time, public: true
  end

  # List all cities
  # Example:
  #  `curl -v -H "Content-type: application/json" 'http://localhost:3000/api/v1/cities.json'`
  def index
    all_cities = City.all
    return json_response([]) unless newest_city = all_cities.sort_by(&:updated_at).first
    Rails.logger.info "newest_city is #{newest_city.inspect}"
    render_if_stale(all_cities, last_modified: newest_city.updated_at.utc, etag: newest_city) do |city_presenters|
      city_presenters.map(&:hash)
    end
    # explicitly setting the Cache-Control response header to public and max-age, to make the response cachable by proxy caches
    expires_in caching_time, public: true
  end

  # Create a new city.
  # Example:
  #  `curl -v -H "Content-type: application/json" -X POST 'http://localhost:3000/api/v1/cities.json' \
  #         -d '{"name":"Hagen","state":"NRW","country":"DE","latitude":51.3474,"longitude":7.4274}'`
  def create
    city = City.find_or_initialize_by(params.slice(:name, :state, :country))
    render(json: {error: "City  [#{params.slice(:name, :state, :country).inspect} already exists."}, status: :conflict) and return unless city.new_record?
    city.assign_attributes(params.slice(:latitude, :longitude))
    if city.save
      render text: '{"success": true}', status: :created, location: city_path(params[:version], city.id)
    else
      Rails.logger.error "cannot create because there were errors saving #{city.attributes.inspect} ... #{city.errors.to_hash}"
      render(json: city.errors, status: :unprocessable_entity)
    end
  end

  # Update an existing city.
  # Example:
  #  `curl -v -H "Content-type: application/json" -X PUT 'http://localhost:3000/api/v1/cities/1.json' \
  #         -d '{"latitude":47.1108}'`
  def update
    @city.assign_attributes(params.slice(:name, :state, :country, :latitude, :longitude))
    if @city.save
      render text: '{"success": true}', status: :no_content, location: city_path(params[:version], @city.id)
    else
      Rails.logger.error "cannot create because there were errors saving #{@city.attributes.inspect} ... #{@city.errors.to_hash}"
      render(json: @city.errors, status: :unprocessable_entity)
    end
  end

  # Delete a city
  # Example:
  #  `curl -v -H "Content-type: application/json" -X DELETE 'http://localhost:3000/api/v1/cities/1.json'`
  def destroy
    if @city.destroy
      render text: '{"success": true}', status: :no_content, location: city_path(params[:version], @city.id)
    else
      Rails.logger.error "cannot destroy city because there were errors deleting the city #{@city.attributes.inspect} ... #{@city.errors.to_hash}"
      render(json: @city.errors, status: :bad_request)
    end
  end

  # Find cities nearby a given city (within an optional radius in miles)
  def nearby
    #TODO
  end

  # Find cities filtered by a given country string
  def in_country
    #TODO
  end

  private

  def find_city
    not_found_with_max_age(caching_time) and return unless (@city = City.find_by_id(params[:id]))
  end
end
