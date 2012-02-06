# Please see LICENSE.txt for copyright and license information.

require 'rack/auth/abstract/request'

# An OAuth flavored extension to Rack::Auth::AbstractRequest
#
module Rack::Auth::Oauth
  class Request < Rack::Auth::AbstractRequest

    # This middleware becomes a Rack endpoint in the following scenarios:
    #
    # returns:
    #   Missing Auth header
    #     response: 401 - "Unauthorized"
    #   Incorrect Auth scheme
    #     response: 401 - "Incorrect authorization scheme, must be OAuth 1.0"
    #   Missing Consumer key
    #     response: 401 - "Unspecified OAuth consumer key"
    #
    def with_valid_request
      if provided?
        if !oauth?
          [401, {}, ["Incorrect authorization scheme, must be OAuth 1.0"]]
        elsif params[:consumer_key].nil?
          [401, {}, ["Unspecified OAuth consumer key"]]
        elsif params[:signature].nil?
          [401, {}, ["Missing signature in OAuth request"]]
        elsif params[:signature_method].nil?
          [401, {}, ["Missing signature method in OAuth request"]]
        else
          yield(request.env)
        end
      else
        [401, {}, ["Unauthorized"]]
      end
    end

    # Verify the request using a clients secret
    #
    # args:
    #   client - A model that has both defines both consumer_secret and consumer_key
    #
    def verify_signature(client)
      return false unless client

      header = SimpleOAuth::Header.new(request.request_method, request.url, included_request_params, auth_header)
      header.valid?(:consumer_secret => client.consumer_secret)
    end

    # Parse the header params from the Authorization header
    #
    def params
      @params ||= SimpleOAuth::Header.parse(auth_header)
    end

    # Grab the consumer key from the header params
    #
    def consumer_key
      params[:consumer_key]
    end

    # Check that the Authorization header is specifying the oauth scheme
    #
    def oauth?
      :oauth == scheme
    end

    private

    def auth_header # :nodoc:
      @env[authorization_key]
    end

    def included_request_params # :nodoc:
      request.content_type == "application/x-www-form-urlencoded" ? request.params : nil
    end

  end
end
