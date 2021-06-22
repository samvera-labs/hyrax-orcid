# frozen_string_literal: true

module Hyrax
  module Orcid
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::Orcid

      # Automount this engine
      # Only do this because this is just for us and we don't need to allow
      # control over the mount to the application
      initializer 'hyku_additions.routes' do |app|
        app.routes.append do
          mount HykuAddons::Engine, at: '/'
        end
      end

      config.after_initialize do
        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths['app/views'].existent)
      end

      # Append our locales so they have precedence
      I18n.load_path += Dir[Hyrax::Orcid::Engine.root.join('config', 'locales', '*.{rb,yml}')]
    end
  end
end
