# Please see LICENSE.txt for copyright and license information.

require 'rack/auth/digest/params'
require 'oauth/helper'

# A class for stripping and chanllenging the Authentication header
#
module Rack::Auth::Oauth
  class Params < Rack::Auth::Digest::Params

    # Use OAuth::Helper to parse Authentication header. The
    # parsed header is passed to self so that an instance of
    # Rack::Auth::Oauth::Params is returned. This is possible
    # because Rack::Auth::Digest::Params inherits from Hash.
    #
    # args:
    #   str - The Authentication header
    #
    def self.parse(str)
      self[OAuth::Helper.parse_header(str)]
    end

    # Check to see if oauth_consumer_key is missing from params hash.
    #
    def missing_consumer_key? # :nodoc:
      self["oauth_consumer_key"].nil?
    end

    # Check to see if oauth_signature is missing from params hash.
    #
    def missing_signature? #:nodoc:
      self["oauth_signature"].nil?
    end

    # Check to see if oauth_signature_method is missing from params hash.
    #
    def missing_signature_method? #:nodoc:
      self["oauth_signature_method"].nil?
    end

  end
end
