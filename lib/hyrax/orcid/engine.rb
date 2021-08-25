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
      initializer "configure" do
        Flipflop::FeatureLoader.current.append(self)
      end

      # Automount this engine
      # Only do this because this is just for us and we don't need to allow control over the mount to the application
      config.after_initialize do
        Rails.application.routes.prepend do
          mount Hyrax::Orcid::Engine => "/"
        end
      end

      def self.dynamically_include_mixins
        # NOTE: This is a temp fix because of development loading issues
        User.include Hyrax::Orcid::UserBehavior
        # ::User.class_eval do
        #   has_one :orcid_identity, dependent: :destroy

        #   def orcid_identity_from_authorization(params)
        #     transformed = params.symbolize_keys
        #     transformed[:orcid_id] = transformed.delete(:orcid)

        #     create_orcid_identity(transformed)
        #   end

        #   def orcid_identity?
        #     orcid_identity.present?
        #   end

        #   def orcid_referenced_works
        #     @_orcid_referenced_works ||= begin
        #       return [] if orcid_identity.blank?

        #       # NOTE: I'm trying to avoid returning ID's and performing a Fedora query if I can help it,
        #       # but if we need to instantiate the Model objects, this can be done by returning just the ID
        #       # options = { fl: [:id], rows: 1_000_000 }

        #       # For some reason, `'` causes the query to return no results, so we need to use `\"`
        #       id = orcid_identity.orcid_id
        #       query_string = "(contributor_tesim:\"*#{id}*\" OR creator_tesim:\"*#{id}*\") AND visibility_ssi:open"
        #       result = ActiveFedora::SolrService.get(query_string, row: 1_000_000)

        #       result['response']['docs'].map { |doc| ActiveFedora::SolrHit.new(doc) }
        #     end
        #   end
        # end

        # Add any required helpers, for routes, api metadata etc
        Hyrax::HyraxHelperBehavior.include Hyrax::Orcid::HelperBehavior

        # Add the JSON processing code to the default presenter
        Hyrax::WorkShowPresenter.prepend Hyrax::Orcid::WorkShowPresenterBehavior

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

      if Rails.env.development?
        config.to_prepare { Hyrax::Orcid::Engine.dynamically_include_mixins }
      else
        config.after_initialize { Hyrax::Orcid::Engine.dynamically_include_mixins }
      end
    end
  end
end
