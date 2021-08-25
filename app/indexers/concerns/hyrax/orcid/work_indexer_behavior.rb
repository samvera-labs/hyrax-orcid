# frozen_string_literal: true

# Inspired by Hyku Addons
# @credit Chris Colvard <chris.colvard@gmail.com>
module Hyrax
  module Orcid
    module WorkIndexerBehavior
      extend ActiveSupport::Concern

      FIELD_ORDERS = {
        creator: ["creator_name", "creator_orcid"],
        contributor: ["contributor_name", "contributor_orcid"]
      }.freeze

      def generate_solr_document
        super.tap do |solr_doc|
          solr_doc["creator_display_ssim"] = format_names(:creator) if object.respond_to?(:creator)
          solr_doc["contributor_display_ssim"] = format_names(:contributor) if object.respond_to?(:contributor)
        end
      end

      private

      def format_names(field)
        return if object&.send(field)&.first.blank?

        JSON.parse(object.send(field).first).collect do |hash|
          hash.slice(*FIELD_ORDERS[field]).values.map(&:presence).compact.map(&:strip).join(', ')
        end
      end
    end
  end
end
