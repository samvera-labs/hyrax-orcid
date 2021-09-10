# frozen_string_literal: true

require "hyrax/orcid/version"
require "hyrax/orcid/engine"
require "hyrax/orcid/errors"
require "flipflop"
require "bolognese"

module Hyrax
  module Orcid
    # Setup a configuration class that allows users to override these settings
    # with their own configuration, or add ENV variables.
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new

      yield(configuration)
    end

    class Configuration
      attr_accessor :client_id, :client_secret, :authorization_redirect_url, :work_reader

      def initialize
        @client_id = ENV["ORCID_CLIENT_ID"]
        @client_secret = ENV["ORCID_CLIENT_SECRET"]
        @authorization_redirect_url = ENV["ORCID_AUTHORIZATION_REDIRECT_URL"]

        @work_reader = {
          reader_class: "Bolognese::Metadata",
          from: "hyrax_work"
        }
      end
    end
  end
end
