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

      context 'client makes request with sufficient, but incorrect OAuth header' do

        let(:test_uri) { "http://example.com" }
        let(:incorrect_secret) { "!!#{DummyClient::DUMMY_SECRET}!!" }
        let(:consumer_credentials) {{ :consumer_key => DummyClient::DUMMY_KEY, :consumer_secret => incorrect_secret }}
        let(:invalid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, test_uri, {}, consumer_credentials).to_s }}

        it 'deems the request unauthorized' do
          resp = mock_request.get(test_uri, invalid_auth_header)
          resp.status.should == 401
        end

      end

      context 'client makes request with sufficient and correct OAuth header' do

        let(:test_uri) { "http://example.com" }
        let(:consumer_credentials) {{ :consumer_key => DummyClient::DUMMY_KEY, :consumer_secret => DummyClient::DUMMY_SECRET }}
        let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, test_uri, {}, consumer_credentials).to_s }}

        context "GET without params" do

          let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, test_uri, {}, consumer_credentials).to_s }}

          it 'has a successful response' do
            resp = mock_request.get(test_uri, valid_auth_header)
            resp.status.should == 200
          end

        end

        context "GET with params" do

          let(:uri_with_params) { "#{test_uri}?foo=bar" }
          let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, uri_with_params, {}, consumer_credentials).to_s }}

          it 'has a successful response' do
            resp = mock_request.get(uri_with_params, valid_auth_header)
            resp.status.should == 200
          end

        end

        context "POST without params" do

          let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:post, test_uri, {}, consumer_credentials).to_s }}

          it 'has a successful response' do
            resp = mock_request.post(test_uri, valid_auth_header)
            resp.status.should == 200
          end

        end

        context "POST with params" do
          context "Content-Type is x-www-form-urlencoded" do

            let(:form_data) {{ :foo => "bar" }}
            let(:post_data) {{ :content_type => "application/x-www-form-urlencoded", :params => form_data}}
            let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:post, test_uri, form_data, consumer_credentials).to_s }}

            it 'has a successful response' do
              resp = mock_request.post(test_uri, valid_auth_header.merge(post_data))
              resp.status.should == 200
            end

          end

          context "Content-Type is anything other than x-www-form-urlencoded" do

            let(:json_data) {{ :foo => "bar"}.to_json }
            let(:post_data) {{ "CONTENT_TYPE" => "application/json", :input => json_data }}
            let(:valid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:post, test_uri, {}, consumer_credentials).to_s }}

            it 'has a successful response' do
              resp = mock_request.post(test_uri, valid_auth_header.merge(post_data))
              resp.status.should == 200
            end

          end
        end
      end
    end
  end
end
