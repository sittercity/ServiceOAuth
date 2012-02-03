# Please see LICENSE.txt for copyright and license information.

require 'rack/auth/oauth/request'
require 'active_support/inflector/methods'

# Middleware for tokenless OAuth 1.0 provider
#
module Rack::Auth::Oauth
  class Tokenless
    attr_reader :request, :client, :client_class_name

    # Sets the the app that the middleware delegates to
    #
    # params:
    #   app - a rack endpoint or middleware
    #
    def initialize(app, client_class_name="Client")
      @app               = app
      @client_class_name = client_class_name
    end

    # Implements call according to Rack protocol. Goes through
    # a series of checks against the incoming request ultimately
    # setting a successfully authorized client in request env.
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
          [401, {}, ["Unauthorized"]]
        end
      end
    end

    # Get a reference to the class the middleware user would like
    # to use as a Client
    #
    def client_class
      ActiveSupport::Inflector.constantize(@client_class_name)
    end

    # Find the client based on incoming oauth consumer key
    #
    # returns: the verification status
    #
    def client_verified?
      @client = client_class.find_by_consumer_key(request.consumer_key)
      request.verify_signature(@client)
    end

  end
end
