# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/model_helpers'

module Hyrax
  module Orcid
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      namespace 'hyrax:orcid:install'

      # Same as adding --skip-namespace flag to generator call
      # This removes the hyrax/orcid namespace from class_path
      # Namespaces passed as the argument will still appear in class_path
      class_option :skip_namespace, default: true

      def inject_into_helper
        # rubocop:disable Style/RedundantSelf
        # For some reason I had to use self.destination_root here to get all contexts to work (calling from hyrax app, calling from this engine to test app, rspec tests)
        self.destination_root = Rails.root if self.destination_root.blank? || self.destination_root == Hyrax::Orcid::Engine.root.to_s
        helper_file = File.join(self.destination_root, 'app', 'helpers', "hyrax_helper.rb")
        # rubocop:enable Style/RedundantSelf

        insert_into_file helper_file, after: 'include Hyrax::HyraxHelperBehavior' do
          "\n" \
          "  # Helpers provided by hyrax-orcid plugin.\n" \
          "  include Hyrax::Orcid::HelperBehavior"
        end
      end

      def copy_migrations
        rake "hyrax:orcid:install:migrations"
      end

      def inject_javascript
        insert_into_file(Rails.root.join('app', 'assets', 'javascripts', 'application.js'), after: /require hyrax$/) do
          "\n//= require hyrax/orcid/application"
        end
      end

      def inject_stylesheet
        insert_into_file(Rails.root.join('app', 'assets', 'stylesheets', 'application.css'), after: /require hyrax$/) do
          "\n *= require hyrax/orcid/application"
        end
      end
    end
  end
end
