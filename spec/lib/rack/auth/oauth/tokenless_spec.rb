require 'spec_helper'

describe Rack::Auth::Oauth::Tokenless do
  def dummy_app; lambda{|env| [200, {}, [ env["oauth_client"] ]]}; end

  let(:middleware) { Rack::Auth::Oauth::Tokenless.new(dummy_app) }
  let(:mock_request) { Rack::MockRequest.new(middleware) }

  context 'request has no auth header' do

    it 'returns a 401' do
      mock_request.get("/").status.should == 401
    end

    it 'notifies client that they are unauthorized' do
      mock_request.get("/").body.should == "Unauthorized"
    end

  end

  context 'request has an authorization header' do
    context 'has an incorrect Authorization scheme' do

      it 'returns a 401' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "JUNK").status.should == 401
      end

      it 'notifies client that they are unauthorized' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "JUNK").body.should == "Incorrect authorization scheme, must be OAuth 1.0"
      end

    end

    context 'does not have an oauth_consumer_key' do

      it 'returns a 401' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\"").status.should == 401
      end

      it 'notifies the client that they provided not included their consumer key' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\"").body.should == "Unspecified OAuth consumer key"
      end

    end

    context 'does not have an oauth_signature' do

      it 'returns a 401' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\", oauth_consumer_key=\"123\"").status.should == 401
      end

      it 'notifies the client that they provided not included their consumer key' do
        mock_request.get("/", "HTTP_AUTHORIZATION" => "OAuth realm=\"foo\", oauth_consumer_key=\"123\"").body.should == "Missing signature in OAuth request"
      end

    end

    context 'does not have an oauth_signature_method' do

      it 'returns a 401' do
        auth_header = "OAuth realm=\"foo\", oauth_consumer_key=\"123\", oauth_signature=\"SIGNATURE\""
        mock_request.get("/", "HTTP_AUTHORIZATION" => auth_header).status.should == 401
      end

      it 'notifies the client that they provided not included their consumer key' do
        auth_header = "OAuth realm=\"foo\", oauth_consumer_key=\"123\", oauth_signature=\"SIGNATURE\""
        mock_request.get("/", "HTTP_AUTHORIZATION" => auth_header).body.should == "Missing signature method in OAuth request"
      end

    end

    context 'has oauth_consumer_key, oauth_signature, and oauth_signature_method and specifies OAuth protocol' do

      let!(:env) { Rack::MockRequest.env_for('/') }
      let!(:request) { Rack::Request.new(env) }
      let!(:consumer_key) { DummyClient::DUMMY_KEY }
      let!(:consumer_secret) { DummyClient::DUMMY_SECRET }
      let!(:nonce) { OAuth::Helper.generate_nonce }
      let!(:timestamp) { OAuth::Helper.generate_timestamp }
      let!(:signature_method) { "HMAC-SHA1" }
      # let!(:signature) {
      #   CGI.escape(OAuth::Signature.sign(request, :parameters => {
      #     'oauth_consumer_key' => consumer_key,
      #     'oauth_consumer_secret' => consumer_secret,
      #     'oauth_signature_method' => signature_method,
      #     'oauth_nonce' => nonce,
      #     'oauth_timestamp' => timestamp,
      #     'oauth_version' => '1.0'
      #   }))
      # }
      let!(:consumer) {
        OAuth::Consumer.new(consumer_key, consumer_secret, {})
      }
      let!(:client_helper) {
        OAuth::Client::Helper.new(request, { :consumer => consumer })
      }
      let!(:auth_header) { client_helper.header }
      # let!(:bad_auth_header) {
      #   ["OAuth realm=\"foo\"",
      #    "oauth_consumer_key=\"#{consumer_key}\"",
      #    "oauth_signature=\"#{signature}\"",
      #    "oauth_nonce=\"#{OAuth::Helper.generate_nonce}\"",
      #    "oauth_timestamp=\"#{OAuth::Helper.generate_timestamp}\"",
      #    "oauth_version=\"1.0\"",
      #    "oauth_signature_method=\"#{signature_method}\""].join(',')
      # }

      before do
        Rack::Auth::Oauth::Tokenless.stub(:client_class => 'DummyClient')
      end

      it 'has a successful response' do
        resp = mock_request.get("/", "HTTP_AUTHORIZATION" => auth_header)

        resp.status.should == 200
      end
    end
  end
end
