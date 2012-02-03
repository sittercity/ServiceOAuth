# Purpose

This rack middleware implements a two-legged tokenless OAuth provider.

The protocol is discussed at length at the following link:

[RFC 5849 3.2](http://tools.ietf.org/html/rfc5849#section-3)

# Example Usage

### Rails

Include the middleware in your rails config (for example, in config/application.rb)

```ruby

Example::Application.configure do
  config.middleware.use Rack::Auth::Oauth::Tokenless
end

```

# Contributing

Fork the project, add your fix (with tests), and send a pull request

# TODO

* Improve README.md
* Configure custom client class name

# License

Please see LICENSE.txt for copyright and licensing information.
