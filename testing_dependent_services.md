# Testing with dependent services
---------------------------------

## Approaches

There are three general approaches:

### 1. Mocking / Stubbing of service calls
* Tests (or a general test helper) use stubbing and mocking of the service calls, so that no HTTP calls are ever made
* Results of the service calls are assumed / 'faked', so that the rest of the code under test can be exercised base on these assumptions
* Pros: 
	* fast
* Cons: 
	* The full 'integrated' functionality will never be exercised by the tests
	* If the dependent APIs ever change, the code under test will never know
	* Often lots of (boring, boilerplate, distracting) code is written to boostrap test case

### 2. Tests *always* call dependencies
* The code under test calls all dependent services (in production/development fabric, or locally installed) *every time* the tests run
* Pros: 
	* The test results are always true / reflect the actual service environment and APIs
* Cons: 
	* slow
	* tests can never run in isolation, as services (in production/development fabric, or locally installed) always need to be available during test runs
	* Changes in the dependent services' data can cause 'false negative' test failures
	 
### 3. Tests call dependencies *once* 
* Mixture of the previous two approaches
* Code under tests calls dependent services once, records the responses, and then replays them in future runs.
* Pros:
	* fast *most of the time* (unless during recordings)
	* The test results are *most of the time* true integration / reflect the actual service environment and APIs
	* dependent services never need to be run (or even installed) locally
* Cons:
	* recorded 'canned responses' can get big
	* one will need to find a good freqeuncy for re-recording the canned responses

## Testing with VCR

We recommend using approach number 3 above, and we mainly use [VCR](https://github.com/vcr/vcr).

VCR is very easy to configure, works well with Rails, and if can hook into a large variety of HTTP gems (including [Typhoeus](https://github.com/typhoeus/typhoeus), which is used in our sample services).

As an example, we used it for a single test inside of the `cities_service` repository, performing the following steps:

* Added the `vcr` gem to the `:test` gem group in the `Gemfile` of `cities_service`
* Changed the `test_helper.rb` to configure VCR to hook into `typhoeus`, and recorded *cassettes* (i.e., VCR's term for the recorded, to be replayed service responses) into a special `fixtues/vcr_cassettes` directory, like so:

  ````
	VCR.configure do |c|
  	  c.hook_into :typhoeus
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
	end
  ````
* Recorded, and subsequently used, the cassettes in the tests for the `RemoteTag` class whenever a service call is made in the code under test, i.e.:

  ````
	VCR.use_cassette('tags_bacon')  do
  	  RemoteTag.find_by_name('bacon').name.must_equal 'bacon'
	end
  ````

## Exercise
* add `vcr` and all necessary configuration to your `inventory_service` repository
* write some tests (e.g., unit tests for `RemoteTag` and / or `RemoteCity`) that:
	* exercise, and record results for, calling `city_service` for the city of a given `IntentoryItem`
	* exercise, and record results for, calling `tags_service` for all tags given a list of `IntentoryItem`s
