# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parametrization/version'

Gem::Specification.new do |spec|

  spec.name          = "parametrization"
  spec.version       = Parametrization::VERSION
  spec.summary       = 'Simple, powerful, and flexible parameter filtering for Rails.'
  spec.homepage      = 'https://github.com/rusterholz/parametrization'
  spec.authors       = ["Andy Rusterholz"]
  spec.email         = ["andy@blinker.com"]
  spec.license       = 'MIT'

  spec.description   = 'Parametrization makes it dead-simple to get the parameters you need in the situations you need them.'

  spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }

  spec.require_paths = %w(lib)

  spec.add_dependency 'rails',      '~> 4.2'
  spec.add_dependency 'parametric', '~> 0.0', '>= 0.0.5'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.3'

end
