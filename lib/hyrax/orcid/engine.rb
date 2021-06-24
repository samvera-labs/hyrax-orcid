# frozen_string_literal: true

require 'rails/all'

module Hyrax
  module Orcid
    class Engine < Rails::Engine
      isolate_namespace Hyrax::Orcid

      # Allow flipflop to load config/features.rb from the Hyrax gem:
      initializer 'configure' do
        Flipflop::FeatureLoader.current.append(self)
      end

      config.after_initialize do
        # Hyrax::Dashboard::ProfilesController.prepend HykuAddons::Dashboard::ProfilesControllerBehavior

        User.include Hyrax::Orcid::UserBehavior

        Bolognese::Metadata.prepend Bolognese::Writers::OrcidXmlWriter
        Hyrax::CurationConcern.actor_factory.use Hyrax::Actors::Orcid::PublishWorkActor
        # Because the Hyrax::ModelActor does not call next_actor and continue the chain, we require a new actor
        actors = [Hyrax::Actors::ModelActor, Hyrax::Actors::Orcid::UnpublishWorkActor]
        Hyrax::CurationConcern.actor_factory.insert_before(*actors)

        # Append our locales so they have precedence
        I18n.load_path += Dir[Hyrax::Orcid::Engine.root.join('config', 'locales', '*.{rb,yml}')]

        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths['app/views'].existent)
      end
    end
  end
end
