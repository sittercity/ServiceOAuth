require 'spec_helper'

describe Rack::Auth::Oauth::Tokenless do

  def dummy_app; lambda{|env| [200, {}, []]}; end

  context 'using default client class name' do

    let(:middleware) { Rack::Auth::Oauth::Tokenless.new(dummy_app) }

    it 'defaults client class name to be "Client"' do
      default_class_name = middleware.client_class_name
      default_class_name.should == "Client"
    end

  end

  context 'using custom dummy client class name' do

    let(:middleware) { Rack::Auth::Oauth::Tokenless.new(dummy_app, "DummyClient") }
    let(:mock_request) { Rack::MockRequest.new(middleware) }

    context 'request has no auth header' do

      it 'returns a 401' do
        resp = mock_request.get("/")
        resp.status.should == 401
      end

      it 'notifies client that they are unauthorized' do
        resp = mock_request.get("/")
        resp.body.should == "Unauthorized"
      end

    end

    context 'request has an authorization header' do
      context 'has an incorrect Authorization scheme' do

        let(:bad_header) { "JUNK" }

        it 'returns a 401' do
          resp = mock_request.get("/", "HTTP_AUTHORIZATION" => bad_header)
          resp.status.should == 401
        end

        it 'notifies client that they are unauthorized' do
          resp = mock_request.get("/", "HTTP_AUTHORIZATION" => bad_header)
          resp.body.should == "Incorrect authorization scheme, must be OAuth 1.0"
        end

      end

      context 'does not have an oauth_consumer_key' do

        let(:header_without_consumer_key) {
          { "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\"" }
        }

        it 'returns a 401' do
          resp = mock_request.get("/", header_without_consumer_key)
          resp.status.should == 401
        end

        it 'notifies the client that they provided not included their consumer key' do
          resp = mock_request.get("/", header_without_consumer_key)
          resp.body.should == "Unspecified OAuth consumer key"
        end

      end

      context 'does not have an oauth_signature' do

        let(:header_without_signature) {
          { "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\", oauth_consumer_key=\"123\"" }
        }

        it 'returns a 401' do
          resp = mock_request.get("/", header_without_signature)
          resp.status.should == 401
        end

        it 'notifies the client that they provided not included their consumer key' do
          resp = mock_request.get("/", header_without_signature)
          resp.body.should == "Missing signature in OAuth request"
        end

      end

      context 'does not have an oauth_signature_method' do

        let(:header_without_sig_method) {
          { "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\", oauth_consumer_key=\"123\", oauth_signature=\"SIGNATURE\"" }
        }

        it 'returns a 401' do
          resp = mock_request.get("/", header_without_sig_method)
          resp.status.should == 401
        end

        it 'notifies the client that they provided not included their consumer key' do
          resp = mock_request.get("/", header_without_sig_method)
          resp.body.should == "Missing signature method in OAuth request"
        end

      end

      context 'client secret unsuccessfully authenticates request' do

        let(:env) { Rack::MockRequest.env_for('/') }
        let(:request) { Rack::Request.new(env) }
        let(:consumer_key) { DummyClient::DUMMY_KEY }
        let(:wrong_consumer_secret) { "!#{DummyClient::DUMMY_SECRET}" }
        let(:consumer) { OAuth::Consumer.new(consumer_key, wrong_consumer_secret) }
        let(:client_helper) { OAuth::Client::Helper.new(request, { :consumer => consumer }) }
        let(:valid_auth_header) { { "HTTP_AUTHORIZATION" => client_helper.header } }

        it 'has a successful response' do
          resp = mock_request.get("/", valid_auth_header)
          resp.status.should == 401
        end

      end

      context 'has oauth_consumer_key, oauth_signature, and oauth_signature_method and specifies OAuth protocol' do

        let(:env) { Rack::MockRequest.env_for('/') }
        let(:request) { Rack::Request.new(env) }
        let(:consumer_key) { DummyClient::DUMMY_KEY }
        let(:consumer_secret) { DummyClient::DUMMY_SECRET }
        let(:consumer) { OAuth::Consumer.new(consumer_key, consumer_secret) }
        let(:client_helper) { OAuth::Client::Helper.new(request, { :consumer => consumer }) }
        let(:valid_auth_header) { { "HTTP_AUTHORIZATION" => client_helper.header } }

        it 'has a successful response' do
          resp = mock_request.get("/", valid_auth_header)
          resp.status.should == 200
        end

      end
    end
  end
end
