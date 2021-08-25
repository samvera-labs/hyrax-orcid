# frozen_string_literal: true

module Hyrax
  module Orcid
    module WorkShowPresenterBehavior
      extend ActiveSupport::Concern

      included do
        delegated_methods = [
          :creator_name, :creator_orcid, :creator_display, :contributor_name, :contributor_orcid, :contributor_display
        ].freeze
        delegate(*delegated_methods, to: :solr_document)
      end

      def creator
        involved(:creator)
      end

      def contributor
        involved(:contributor)
      end

      private

      def involved(term)
        involved = JSON.parse(solr_document.public_send(term).first.presence || "[]")

        return if involved.blank?

        involved.pluck("#{term}_name")
      end
    end
  end
end
