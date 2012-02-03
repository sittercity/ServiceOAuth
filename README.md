# Purpose

This rack middleware implements a two-legged tokenless OAuth provider.

The protocol is discussed at length at the following link:

[RFC 5849 3.2](http://tools.ietf.org/html/rfc5849#section-3)

# Example Usage

### Rails

Include the middleware in your rails config (for example, in config/application.rb)

```ruby

Example::Application.configure do
  # Client class will default to Client if not passed a custom class name
  config.middleware.use Rack::Auth::Oauth::Tokenless, "CustomClientClass"
end

```

### "Client" Class Expectations

* Must define both consumer_key and consumer_secret attributes
* "Client" class must respond to YourClientClass#find_by_consumer_key(consumer_key)

# Contributing

Fork the project, add your fix (with tests), and send a pull request

# TODO

* Improve README.md

# License

Please see LICENSE.txt for copyright and licensing information.
