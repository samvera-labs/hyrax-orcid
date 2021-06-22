# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative 'lib/hyrax/orcid/version'

Gem::Specification.new do |spec|
  spec.name          = "hyrax-orcid"
  spec.version       = Hyrax::Orcid::VERSION
  spec.authors       = ["Paul Danelli"]
  spec.email         = ["prdanelli@gmail.com"]

  spec.summary       = "Hyrax/Hyku plugin for interacting with ORCID"
  spec.description   = "Tools to link a repository profile with ORCID and process works"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"

  spec.add_dependency "hyrax", "~> 2.9"
  spec.add_dependency "flipflop", "~> 2.3"
  spec.add_dependency "bolognese", "~> 1.8", ">= 1.8.6"

  spec.add_development_dependency 'flipflop'
  spec.add_development_dependency 'ammeter'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'chromedriver-helper', '~> 2.1'
  spec.add_development_dependency "bixby"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "pg"
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'webdrivers', '~> 4.0'
  spec.add_development_dependency 'webmock'
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  spec.add_development_dependency('simplecov', '0.17.1', '< 0.18')
end
