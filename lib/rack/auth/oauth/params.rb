require 'rack/auth/digest/params'
require 'oauth/helper'

module Rack::Auth::Oauth
  class Params < Rack::Auth::Digest::Params

    def self.parse(str)
      Params[OAuth::Helper.parse_header(str)]
    end

    def missing_consumer_key? # :nodoc:
      self["oauth_consumer_key"].nil?
    end

    def missing_signature? #:nodoc:
      self["oauth_signature"].nil?
    end

    def missing_signature_method? #:nodoc:
      self["oauth_signature_method"].nil?
    end

  end
end
