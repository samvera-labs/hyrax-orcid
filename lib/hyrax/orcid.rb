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
      load_configuration

      yield(configuration)
    end

    def self.reset_configuration
      self.configuration = nil

      load_configuration
    end

    def self.load_configuration
      self.configuration ||= Configuration.new
    end

    class Configuration
      attr_accessor :client_id, :client_secret, :authorization_redirect_url, :bolognese, :active_job_type

      def initialize
        @client_id = ENV["ORCID_CLIENT_ID"]
        @client_secret = ENV["ORCID_CLIENT_SECRET"]
        @authorization_redirect_url = ENV["ORCID_AUTHORIZATION_REDIRECT_URL"]

        @bolognese = {
          # The work reader method, excluding the _reader suffix
          reader_method: "hyrax_work", 
          # The XML builder class that provides the XML body which is sent to Orcid
          xml_builder_class_name: "Bolognese::Writers::Orcid::HyraxXmlBuilder"
        }

        # How to perform the active jobs that are created. This is useful for debugging the jobs and 
        # generated XML or if you want to run all jobs inline.
        # `:perform_later` or `:perform_now` 
        @active_job_type = :perform_later
      end
    end
  end
end
