# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "traject_plus/version"

Gem::Specification.new do |spec|
  spec.name          = "traject_plus"
  spec.version       = TrajectPlus::VERSION
  spec.authors       = ["Chris Beer", "Christina Harlow", "Aaron Collier", "Justin Coyne"]
  spec.email         = ["cabeer@stanford.edu", "cmharlow@stanford.edu", "amcollie@stanford.edu", "jcoyne85@stanford.edu"]

  spec.summary       = "Extensions to Traject for non-MARC formats"
  spec.description   = "Extensions to Traject for non-MARC formats"
  spec.homepage      = "https://github.com/sul-dlss/traject_plus"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'jsonpath'
  spec.add_dependency 'traject', '~> 3.0'
  spec.add_dependency 'deprecation'

  spec.add_development_dependency "bundler", '>= 1.15'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'byebug'
end
