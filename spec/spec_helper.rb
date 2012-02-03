require 'bundler/setup'
require 'rspec'
require 'rack'
require 'rack-auth-oauth-tokenless'

Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|
end
