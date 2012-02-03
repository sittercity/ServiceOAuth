require 'rack/auth/oauth/request'
require 'active_support/inflector/methods'

# middleware for tokenless OAuth 1.0 provider
module Rack::Auth::Oauth
  class Tokenless
    attr_reader :request, :client

    # Sets the the app that the middleware delegates to
    #
    # params:
    #   app - a rack endpoint or middleware
    #
    def initialize(app)
      @app = app
    end

    # Implements call according to Rack protocol
    #
    # params:
    #   env - Rack env
    #
    def call(env)
      @request = Request.new(env)

      @request.with_valid_request do
        if client_verified?
          env["oauth_client"] = client
          @app.call(env)
        else
          [401, {}, "Unauthorized"]
        end
      end
    end

    def client_class
      ActiveSupport::Inflector.constantize(self.class.client_class)
    end

    # TODO: make this a config option passed to use
    def self.client_class
      'Client'
    end

    # find the client based on incoming oauth consumer key
    # returns the verification status
    def client_verified?
      @client = client_class.find_by_consumer_key(request.consumer_key)
      request.verify_signature(@client)
    end

  end
end
