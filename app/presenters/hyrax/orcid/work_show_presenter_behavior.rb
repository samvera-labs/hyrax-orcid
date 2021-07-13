# frozen_string_literal: true

module Hyrax
  module Orcid
    module WorkShowPresenterBehavior
      extend ActiveSupport::Concern

      def creator
        creator = JSON.parse(solr_document.creator.first.presence || "[]")

        return if creator.blank?

        Array.wrap creator.first.dig("creator_name")
      end
    end
  end
end
