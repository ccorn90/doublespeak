# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doublespeak/version'

Gem::Specification.new do |spec|
  spec.name          = "doublespeak"
  spec.version       = Doublespeak::VERSION
  spec.authors       = ["ccorn90"]
  spec.email         = [""]
  spec.summary       = %q{Typeahead entry for Ruby command-line applications}
  spec.description   = %q{Typeahead entry for Ruby command-line applications}
  spec.homepage      = "https://github.com/ccorn90/doublespeak"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '>= 1.5.0', '< 2.0'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_runtime_dependency 'tty-reader'
  spec.add_runtime_dependency 'pastel', '~> 0.7'
end
