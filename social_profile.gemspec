# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'social_profile/version'

Gem::Specification.new do |spec|
  spec.name          = "social_profile"
  spec.version       = SocialProfile::VERSION
  spec.authors       = ["Igor Galeta"]
  spec.email         = ["galeta.igor@gmail.com"]
  spec.description   = %q{Wrapper for Omniauth profile hash, post photo to album}
  spec.summary       = %q{Wrapper for Omniauth profile hash}
  spec.homepage      = "https://github.com/galetahub/social_profile"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "fb_graph", '~> 2.7.16'
  spec.add_dependency "vkontakte", '~> 0.0.6'
  spec.add_dependency "twitter", '~> 5.11.0'
  spec.add_dependency "httpclient"
  spec.add_dependency "multi_json"
end
