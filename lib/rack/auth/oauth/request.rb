# Please see LICENSE.txt for copyright and license information.

require 'rack/auth/abstract/request'
require 'rack/auth/oauth/params'
require 'oauth'
require 'oauth/request_proxy/rack_request'

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
        elsif params.missing_consumer_key?
          [401, {}, ["Unspecified OAuth consumer key"]]
        elsif params.missing_signature?
          [401, {}, ["Missing signature in OAuth request"]]
        elsif params.missing_signature_method?
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
      OAuth::Signature.verify(request, :consumer_secret => client.consumer_secret)
    end

    def consumer_key
      params['oauth_consumer_key']
    end

    def params
      @params ||= Params.parse(@env[authorization_key])
    end

    def oauth?
      :oauth == scheme
    end

  end
end
