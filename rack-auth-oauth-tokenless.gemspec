# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Jones", "Tony Schneider"]
  gem.email         = ["matt.jones@edgecase.com", "tony@edgecase.com"]
  gem.description   = %q{OAuth 1.0 server}
  gem.summary       = %q{OAuth 1.0 Rack middleware for tokenless authentication}
  gem.homepage      = "http://sittercity.com"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rack-auth-oauth-tokenless"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  gem.add_dependency 'simple_oauth'
  gem.add_dependency 'activesupport', '>= 3.0.0'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'rack-test'
end
