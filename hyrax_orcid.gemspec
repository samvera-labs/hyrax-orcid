# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "lib/hyrax/orcid/version"

Gem::Specification.new do |spec|
  spec.name          = "hyrax-orcid"
  spec.version       = Hyrax::Orcid::VERSION
  spec.authors       = ["Paul Danelli"]
  spec.email         = ["tech@ubiquitypress.com", "prdanelli@gmail.com"]

  spec.summary       = "Hyrax plugin for interacting with ORCID"
  spec.description   = "Tools to link a repository profile with ORCID and process works"
  spec.homepage      = "https://github.com/ubiquitypress/hyrax-orcid"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # rubocop:disable Style/GuardClause
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end
  # rubocop:enable Style/GuardClause

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"
  spec.add_dependency "hyrax", "~> 2.9"
  spec.add_dependency "flipflop", "~> 2.6"
  spec.add_dependency "bolognese", "~> 1.9", ">= 1.9.9"

  spec.add_development_dependency "flipflop", "~> 2.6"
  spec.add_development_dependency "ammeter", "~> 1.1"
  spec.add_development_dependency "capybara", "~> 3.35"
  spec.add_development_dependency "chromedriver-helper", "~> 2.1"
  spec.add_development_dependency "bixby", "~> 1.0.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.2"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4"
  spec.add_development_dependency "rspec-rails", "~> 2.2"
  spec.add_development_dependency "shoulda-matchers", "~> 5.0"
  spec.add_development_dependency "webdrivers", "~> 4.0"
  spec.add_development_dependency "webmock", "~> 3.14"
  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "web-console", "~> 3.7"

  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  spec.add_development_dependency("simplecov", "0.17.1", "< 0.18")
end
