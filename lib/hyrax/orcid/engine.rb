# frozen_string_literal: true

require 'rails/all'

module Hyrax
  module Orcid
    class Engine < Rails::Engine
      isolate_namespace Hyrax::Orcid

      config.after_initialize do
        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths['app/views'].existent)
      end

      # Allow flipflop to load config/features.rb from the Hyrax gem:
      initializer 'configure' do
        Flipflop::FeatureLoader.current.append(self)
      end

      # Append our locales so they have precedence
      I18n.load_path += Dir[Hyrax::Orcid::Engine.root.join('config', 'locales', '*.{rb,yml}')]
    end
  end
end
