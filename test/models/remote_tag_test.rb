require 'test_helper'

describe RemoteTag do
  describe "#find_by_city_ids" do
    it "has the correct number of tags for a city" do
      VCR.use_cassette('tags_city_id_1')  do
        RemoteTag.find_by_city_ids([1]).must_equal []
      end
    end
  end

  describe "#find_by_name" do
    it "finds a tag by name" do
      VCR.use_cassette('tags_bacon')  do
        RemoteTag.find_by_name('bacon').name.must_equal 'bacon'
      end
    end
  end
end
