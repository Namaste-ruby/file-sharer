ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

include Rack::Test::Methods

def app
  FileSharingAPI
end

def invalid_id(resource)
  (resource.max(:id) || 0) + 1
end