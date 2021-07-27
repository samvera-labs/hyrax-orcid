# frozen_string_literal: true

module Hyrax
  module Orcid
    module WorkShowPresenterBehavior
      extend ActiveSupport::Concern

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
