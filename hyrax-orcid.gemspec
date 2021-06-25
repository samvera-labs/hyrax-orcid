# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative 'lib/hyrax/orcid/version'

Gem::Specification.new do |spec|
  spec.name = "hyrax-orcid"
  spec.version       = Hyrax::Orcid::VERSION
  spec.authors       = ["Paul Danelli"]
  spec.email         = ["prdanelli@gmail.com"]

  spec.summary       = "Hyrax/Hyku plugin for interacting with ORCID"
  spec.description   = "Tools to link a repository profile with ORCID and process works"
  spec.homepage      = "https://github.com/ubiquitypress/hyrax-orcid"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.files        = `git ls-files`.split("\n")
  spec.executables  = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_path = 'lib'

  # rubocop:disable Style/GuardClause
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end
  # rubocop:enable Style/GuardClause

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ubiquitypress/hyrax-orcid"
  spec.metadata["changelog_uri"] = "https://github.com/ubiquitypress/hyrax-orcid/blob/master/CHANGELOG.md"

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"
  spec.add_dependency "hyrax", "~> 2.9"
  spec.add_dependency "flipflop", "~> 2.6"
  spec.add_dependency "bolognese", "~> 1.9", ">= 1.9.9"

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
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'web-console'

  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  spec.add_development_dependency('simplecov', '0.17.1', '< 0.18')
end
