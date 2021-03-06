# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
# require File.expand_path('internal_test_hyrax/spec/rails_helper.rb', __dir__)

ENV['RAILS_ENV'] ||= 'test'

# HACK: Not sure why this is required, but otherwise Rails.env will be set to development
Rails.env = ENV["RAILS_ENV"]
require File.expand_path('internal_test_hyrax/config/environment', __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'factory_bot_rails'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'webdrivers'
require 'webdrivers/chromedriver'
require 'active_fedora/cleaner'
require 'noid/rails/rspec'
require 'devise'
require 'devise/version'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')

Rails.application.routes.default_url_options[:host] = 'www.example.com'

# Try and suppress depreciation warnings
ActiveSupport::Deprecation.silenced = true

# This avoids us having issues with the test hyrax app factories being registered
# FactoryBot.definition_file_paths = [Rails.root.join("..", "..", "spec", "factories")]
# FactoryBot.find_definitions

# Add additional requires below this line. Rails is not loaded until this point!
# For testing generators
require 'ammeter/init'

# Capybara config copied over from Hyrax
Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--no-sandbox'
  # browser_options.args << '--disable-dev-shm-usage'
  # browser_options.args << '--disable-extensions'
  # client = Selenium::WebDriver::Remote::Http::Default.new
  # client.timeout = 90 # instead of the default 60
  # Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, http_client: client)
  browser_options.args << '--window-size=2880,1680'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :rack_test # This is a faster driver
Capybara.javascript_driver = :selenium_chrome_headless_sandboxless # This is slower
Capybara.default_max_wait_time = 10 # We may have a slow application, let's give it some time.

# FIXME: Pin to older version of chromedriver to avoid issue with clicking non-visible elements
# Webdrivers::Chromedriver.required_version = '72.0.3626.69'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
# Note: engine, not Rails.root context.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

require 'shoulda-matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  include Noid::Rails::RSpec
  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }

  if Devise::VERSION >= '4.2'
    config.include Devise::Test::ControllerHelpers, type: :controller
  else
    config.include Devise::TestHelpers, type: :controller
  end

  config.before do
    ActiveJob::Base.queue_adapter = :test
  end

  config.before do |example|
    # Pass `:clean' to destroy objects in fedora/solr and start from scratch
    ActiveFedora::Cleaner.clean! if example.metadata[:clean]
  end

  # Internal Tests to skip
  # Make sure this around is declared first so it runs before other around callbacks
  skip_internal_test_list = ['./spec/internal_test_hyrax/spec/features/create_generic_work_spec.rb']
  config.around do |example|
    if skip_internal_test_list.include? example.file_path
      skip "Internal test skipped."
    else
      example.run
    end
  end

  # Configuration for feature tests
  config.include Features::SessionHelpers, type: :feature
  config.include Warden::Test::Helpers, type: :feature

  config.after(:each, type: :feature) do
    Warden.test_reset!
    Capybara.reset_sessions!
    page.driver.reset!
  end

  config.before(:all, type: :feature) do
    visit "/assets/application.css"
    visit "/assets/application.js"
  end
end
