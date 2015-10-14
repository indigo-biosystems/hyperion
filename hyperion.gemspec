# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyperion/aux/version'

Gem::Specification.new do |spec|
  spec.name          = 'hyperion'
  spec.version       = Hyperion::VERSION
  spec.authors       = ['Indigo BioAutomation, Inc.']
  spec.email         = ['pwinton@indigobio.com']
  spec.summary       = 'Ruby REST client'
  spec.description   = 'Ruby REST client for internal Indigo BioAutomation service architecture'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'json_spec'
  spec.add_development_dependency 'rspec_junit_formatter'

  spec.add_runtime_dependency 'abstractivator', '~> 0.0'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'immutable_struct', '~> 1.1'
  spec.add_runtime_dependency 'oj', '~> 2.12'
  spec.add_runtime_dependency 'typhoeus', '~> 0.7'
  spec.add_runtime_dependency 'mimic', '~> 0.4.3'
end
