# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroku/version'

Gem::Specification.new do |spec|
  spec.name          = "heroku-platform-api"
  spec.version       = Heroku::VERSION
  spec.authors       = ["Ashok Menon", "Rentify"]
  spec.email         = ["amenon94@gmail.com", "dev@rentify.com"]
  spec.description   = %q{Create, destroy and manage your heroku applications programmatically, using the Heroku Platform API.}
  spec.summary       = %q{Ruby client for the Heroku Platform API.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "git"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
