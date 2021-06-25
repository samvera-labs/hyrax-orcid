# frozen_string_literal: true

require "bundler/setup"
require "hyrax/orcid"
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true,
                                 allow: [
                                   'hyku-carrierwave-test.s3.amazonaws.com',
                                   'fcrepo',
                                   'solr',
                                   'chrome',
                                   'chromedriver.storage.googleapis.com'
                                 ])
  end
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Look for an overriding spec file and skip if it exists
  config.around do |example|
    if example.file_path.starts_with?('./spec/internal_test_hyrax') && File.exist?(example.file_path.sub('./spec/internal_test_hyrax', '.'))
      skip "Override exists of this test file in engine."
    else
      example.run
    end
  end
end

require File.expand_path('internal_test_hyrax/spec/rails_helper.rb', __dir__)
require File.expand_path('internal_test_hyrax/spec/spec_helper.rb', __dir__)
