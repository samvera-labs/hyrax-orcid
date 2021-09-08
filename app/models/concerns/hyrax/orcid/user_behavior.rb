# frozen_string_literal: true

module Hyrax
  module Orcid
    module UserBehavior
      extend ActiveSupport::Concern

      included do
        has_one :orcid_identity, dependent: :destroy
      end

      def orcid_identity_from_authorization(params)
        transformed = params.symbolize_keys
        transformed[:orcid_id] = transformed.delete(:orcid)

        create_orcid_identity(transformed)
      end

      def orcid_identity?
        orcid_identity.present?
      end

      def orcid_referenced_works
        @_orcid_referenced_works ||= begin
          return [] if orcid_identity.blank?

          # NOTE: I'm trying to avoid returning ID's and performing a Fedora query if I can help it,
          # but if we need to instantiate the Model objects, this can be done by returning just the ID
          # options = { fl: [:id], rows: 1_000_000 }

          # For some reason, `'` causes the query to return no results, so we need to use `\"`
          query_string = "work_orcids_tsim:#{orcid_identity.orcid_id} AND visibility_ssi:open"
          result = ActiveFedora::SolrService.get(query_string, row: 1_000_000)

          result["response"]["docs"].map { |doc| ActiveFedora::SolrHit.new(doc) }
        end
      end
    end
  end
end
