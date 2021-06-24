# frozen_string_literal: true
source 'https://rubygems.org' do
  # Please see hyrax-orcid.gemspec for dependency information.
  gemspec name: 'hyrax-orcid'

  group :development, :test do
    gem 'pry' unless ENV['CI']
    gem 'pry-byebug' unless ENV['CI']
    gem 'ruby-prof', require: false
    gem "simplecov", require: false
  end
end
