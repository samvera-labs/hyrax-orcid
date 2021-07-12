# frozen_string_literal: true

module Hyrax
  module Orcid
    module WorkShowPresenterBehavior
      extend ActiveSupport::Concern

      included do
        delegate :creator, to: :hyrax_orcid_creator
      end

      def hyrax_orcid_creator
        @_hyrax_orcid_creator ||= JSON.parse(solr_document.creator.first.presence || "[]")
      end
    end
  end
end
