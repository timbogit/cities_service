class CitiesController < ApplicationController
  before_action :find_city, except: [:index, :create]
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

  # Create a new tag.
  # Example:
  #  `curl -v -H "Content-type: application/json" -X POST 'http://localhost:3000/api/v1/cities.json' \
  #         -d '{"name":"Hagen","state":"NRW","country":"DE","latitude":51.3474,"longitude":7.4274}'`
  def create
    city = City.find_or_initialize_by(params.slice(:name, :state, :country))
    render(json: {error: "City  [#{params.slice(:name, :state, :country).inspect} already exists."}, status: :conflict) and return unless city.new_record?
    city.latitude = params[:latitude]
    city.longitude = params[:longitude]
    if city.save
      render text: '{"success": true}', status: :created, location: city_path(params[:version], city.id)
    else
      Rails.logger.error "cannot create because there were errors saving #{city.attributes.inspect} ... #{city.errors.to_hash}"
      render(json: city.errors, status: :unprocessable_entity)
    end
  end

  # Update an existing tag.
  # Example:
  #  `curl -v -H "Content-type: application/json" -X PUT 'http://localhost:3000/api/v1/tags/android.json' \
  #         -d '{"name":"paranoid"}'`
  def update
    # tag = Tag.find_by_name(params[:id])
    # render(json: {error: "Tag with name #{params[:id]} does not exists."}, status: :not_found) and return if tag.nil?
    # tag.name = params[:name]
    # if tag.save
    #   render text: '{"success": true}', status: :no_content, location: tag_path(params[:version], tag.name)
    # else
    #   Rails.logger.error "cannot create because there were errors saving #{tag.attributes.inspect} ... #{tag.errors.to_hash}"
    #   render(json: tag.errors, status: :unprocessable_entity)
    # end
  end

  # Delete a tag
  # Example:
  #  `curl -v -H "Content-type: application/json" -X DELETE 'http://localhost:3000/api/v1/tags/paranoid.json'`
  def destroy
    # tag = Tag.find_by_name(params[:id])
    # render(json: {error: "Tag with name #{params[:id]} does not exists."}, status: :not_found) and return if tag.nil?
    # if tag.destroy
    #   render text: '{"success": true}', status: :no_content, location: tag_path(params[:version], tag.name)
    # else
    #   Rails.logger.error "cannot destroy tag because there were errors deleting the tag #{tag.attributes.inspect} ... #{tag.errors.to_hash}"
    #   render(json: tag.errors, status: :bad_request)
    # end
  end

  def nearby
  end

  def in_country
  end

  private

  def find_city
    not_found_with_max_age(caching_time) and return unless (@city = City.find_by_id(params[:id]))
  end
end
