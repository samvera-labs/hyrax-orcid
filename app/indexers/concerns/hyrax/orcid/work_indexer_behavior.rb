# frozen_string_literal: true

# Inspired by Hyku Addons
# @credit Chris Colvard <chris.colvard@gmail.com>
module Hyrax
  module Orcid
    module WorkIndexerBehavior
      extend ActiveSupport::Concern

      include Hyrax::Orcid::OrcidHelper

      FIELD_ORDERS = {
        creator: ["creator_name", "creator_orcid"],
        contributor: ["contributor_name", "contributor_orcid"]
      }.freeze

      # Instead of text searching for Orcid IDs, this method will extrct a list of Orcid IDs from the
      # work contributors and store those in a Solr array.
      def generate_solr_document
        super.tap do |solr_doc|
          FIELD_ORDERS.keys.each do |field|
            solr_doc["#{field}_display_ssim"] = format_names(field) if object.respond_to?(field)
          end

          solr_doc["work_orcids_tsim"] = extract_orcids
        end
      end

      private

        def format_names(field)
          json = extract_field_json(field)

          return if json.blank?

          json.collect do |hash|
            hash
              .then { |h| h.slice(*FIELD_ORDERS[field]) }
              .then(&:values)
              .then { |a| a.map(&:presence).compact.map(&:strip) }
              .then { |a| a.join(', ') }
          end
        end

        def extract_orcids
          FIELD_ORDERS
            .keys
            .then { |a| a.map { |field| extract_field_json(field) } }
            .then(&:flatten)
            .then(&:compact)
            .then { |a| a.pluck(*orcid_keys) }
            .then(&:flatten)
            .then { |a| a.reject(&:blank?) }
            .then { |a| a.map { |v| validate_orcid(v) } }
        end

        def extract_field_json(field)
          JSON.parse(object.send(field).first || "")
        rescue JSON::ParserError
          nil
        end

        def orcid_keys
          FIELD_ORDERS.values.flatten.select { |v| v.match?(/_orcid/) }
        end
    end
  end
end
