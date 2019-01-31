ENV['RACK_ENV'] = 'test'

require File.expand_path('../../lib/db', __FILE__)
Dir["#{ROOT_DIR}/spec/support/**/*.rb"].each { |f| require f }

# require 'webmock/rspec'
# WebMock.disable_net_connect! allow_localhost: true

# require "active_support/core_ext/string/strip"

module SpecHelperMethods
  FIXTURES_PATH = "#{ROOT_DIR}/spec/support/fixtures".freeze
end

module ControllerSpecHelperMethods
  
  def get_auth(login: 'foo@bar.com', password: 'foobar')
    post '/login', login: login, password: password
    
    last_response.headers['Authorization']
  end
  
  def jpost(uri, json = {})
    json = json.to_json unless json.is_a? String

    post uri, json, 'CONTENT_TYPE' => 'application/json'
  end
  
  def jput(uri, json = {})
    json = json.to_json unless json.is_a? String

    put uri, json, 'CONTENT_TYPE' => 'application/json'
  end

  def jresponse
    return nil if last_response.body.blank?
    JSON.parse(last_response.body)
  end
end

RSpec::Matchers.define :be_a_model do |expected|
  match do |actual|
    expected === actual
  end
end
RSpec::Matchers.alias_matcher :a_model, :be_a_model

RSpec::Matchers.define :include_records do |expected|
  match do |actual|
    expected = Array(expected)
    actual = actual.kind_of?(Sequel::Dataset) ? actual.all : actual
    
    return false if actual.empty? && !expected.empty?
    
    expected.all? do |candidate|
      actual.any? {|result| result === candidate}
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include SpecHelperMethods
  config.include Rack::Test::Methods, type: :controller
  config.include ControllerSpecHelperMethods, type: :controller

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  
  config.define_derived_metadata(file_path: %r{/spec/integration/}) do |metadata|
    metadata[:type] = :integration
  end
  
  config.define_derived_metadata(file_path: %r{/spec/controllers/}) do |metadata|
    metadata[:type] = :controller
  end
  
  config.before(:suite) do
    DatabaseCleaner[:sequel].clean_with :truncation, reset_ids: true
  end
  
  config.before(:each) do |example|
    DatabaseCleaner[:sequel].strategy = example.metadata[:type] == :integration ? :truncation : :transaction
    DatabaseCleaner.start
    DB[:account_statuses].import([:id, :name], [[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']])
  end
    
  config.append_after(:each) do |example|    
    DatabaseCleaner.clean
    AuthenticatedController.test_user = nil if defined? AuthenticatedController
  end
  
end

FactoryGirl::SyntaxRunner.include SpecHelperMethods
