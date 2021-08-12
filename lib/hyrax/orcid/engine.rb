# frozen_string_literal: true

require 'rails/all'

module Hyrax
  module Orcid
    class Engine < Rails::Engine
      isolate_namespace Hyrax::Orcid

      config.before_initialize do
        if Rails.env.development?
          Rails.application.configure do
            config.eager_load = true
          end
        end
      end

      # Allow flipflop to load config/features.rb from the Hyrax gem:
      initializer 'configure' do
        Flipflop::FeatureLoader.current.append(self)
      end

      # Automount this engine
      # Only do this because this is just for us and we don't need to allow control over the mount to the application
      config.after_initialize do
        Rails.application.routes.prepend do
          mount Hyrax::Orcid::Engine => '/'
        end
      end

      def self.dynamically_include_mixins
        User.include Hyrax::Orcid::UserBehavior

        Hyrax::HyraxHelperBehavior.include Hyrax::Orcid::HelperBehavior
        Hyrax::GenericWorkForm.include Hyrax::Orcid::GenericWorkFormBehavior
        Hyrax::WorkShowPresenter.prepend Hyrax::Orcid::WorkShowPresenterBehavior
        GenericWork.include Hyrax::Orcid::WorkBehavior

        Bolognese::Metadata.prepend Bolognese::Writers::Orcid::XmlWriter
        Bolognese::Metadata.prepend Bolognese::Readers::Orcid::HyraxWorkReader
        # TODO: Remove this when PR#121 is merged
        Bolognese::Metadata.prepend Bolognese::UtilsBehaviors

        # Because the Hyrax::ModelActor does not call next_actor and continue the chain
        # for destroy requests, we require a new actor
        actors = [Hyrax::Actors::ModelActor, Hyrax::Actors::Orcid::UnpublishWorkActor]
        Hyrax::CurationConcern.actor_factory.insert_before(*actors)
        Hyrax::CurationConcern.actor_factory.use Hyrax::Actors::Orcid::PublishWorkActor

        # Insert an extra step in the Blacklight rendering pipeline where our JSON can be parsed
        Blacklight::Rendering::Pipeline.operations.insert(1, Hyrax::Orcid::Blacklight::Rendering::PipelineJsonExtractor)

        # Append our locales so they have precedence
        I18n.load_path += Dir[Hyrax::Orcid::Engine.root.join('config', 'locales', '*.{rb,yml}')]

        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths['app/views'].existent)

        Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, Hyrax::Actors::Orcid::JSONFieldsActor
      end

      if Rails.env.development?
        config.to_prepare { Hyrax::Orcid::Engine.dynamically_include_mixins }
      else
        config.after_initialize { Hyrax::Orcid::Engine.dynamically_include_mixins }
      end
    end
  end
end
