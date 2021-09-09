# frozen_string_literal: true

require 'rails/all'

module Hyrax
  module Orcid
    class Engine < Rails::Engine
      isolate_namespace Hyrax::Orcid

      # Allow flipflop to load config/features.rb from the Hyrax gem:
      initializer "configure" do
        Flipflop::FeatureLoader.current.append(self)
      end

      config.after_initialize do
        Rails.application.routes.prepend do
          mount Hyrax::Orcid::Engine => "/"
        end

        User.include Hyrax::Orcid::UserBehavior

        # Add any required helpers, for routes, api metadata etc
        Hyrax::HyraxHelperBehavior.include Hyrax::Orcid::HelperBehavior

        # Add the JSON processing code to the default presenter
        Hyrax::WorkShowPresenter.prepend Hyrax::Orcid::WorkShowPresenterBehavior

        # Allow the JSON fields to be indexed individually
        Hyrax::WorkIndexer.include Hyrax::Orcid::WorkIndexerBehavior

        # All work types and their forms will require the following concerns to be included
        Hyrax::GenericWorkForm.include Hyrax::Orcid::WorkFormBehavior
        GenericWork.include Hyrax::Orcid::WorkBehavior

        # Insert our custom reader and writer to process works ready before publishing
        Bolognese::Metadata.prepend Bolognese::Writers::Orcid::XmlWriter
        Bolognese::Metadata.prepend Bolognese::Readers::Orcid::HyraxWorkReader

        # Because the Hyrax::ModelActor does not call next_actor to continue the chain,
        # for destroy requests, we require a new actor
        actors = [Hyrax::Actors::ModelActor, Hyrax::Actors::Orcid::UnpublishWorkActor]
        Hyrax::CurationConcern.actor_factory.insert_before(*actors)

        # Insert the publish actor at the end of the chain so we only publish a fully processed work
        Hyrax::CurationConcern.actor_factory.use Hyrax::Actors::Orcid::PublishWorkActor

        # Insert an extra step in the Blacklight rendering pipeline where our JSON can be parsed
        Blacklight::Rendering::Pipeline.operations.insert(1, Hyrax::Orcid::Blacklight::Rendering::PipelineJsonExtractor)

        # Insert our JSON actor before the Model is saved
        Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::ModelActor, Hyrax::Actors::Orcid::JSONFieldsActor

        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths["app/views"].existent)

        # Append our locales so they have precedence
        I18n.load_path += Dir[Hyrax::Orcid::Engine.root.join("config", "locales", "*.{rb,yml}")]
      end
    end
  end
end
