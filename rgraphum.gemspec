# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rgraphum/version'

Gem::Specification.new do |spec|
  spec.name          = "rgraphum"
  spec.version       = Rgraphum::VERSION
  spec.authors       = ["omi", "ice"]
  spec.email         = ["rgraphum@rgraphum.com"]
  spec.description   = %q{Rgraphum: Graphum ruby implementation}
  spec.summary       = %q{Graphum is graph, vertex and edge manipulation library.}
  spec.homepage      = "http://rgraphum.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.has_rdoc      = 'yard'

  spec.add_runtime_dependency "builder"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "hiredis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency 'yard'
end
