# frozen_string_literal: true

module Hyrax
  module Orcid
    class WorkOrcidExtractor
      include Hyrax::Orcid::WorkFormNameHelper
      include Hyrax::Orcid::OrcidHelper

      def initialize(work)
        @work = work
        @orcids = []
      end

      def extract
        target_terms.each do |term|
          target = "#{term}_orcid"
          json = json_for_term(term)

          next if json.blank?

          json.then { |j| JSON.parse(j) }
              .select { |person| person.dig(target).present? }
              .each { |person| @orcids << validate_orcid(person.dig(target)) }
        end

        @orcids.compact.uniq

      # If we have no JSON fields, like in default Hyrax, then we should not crash
      rescue JSON::ParserError
        []
      end

      # FIXME: `GenericWork.json_fields` could be a configuration option
      def target_terms
        (GenericWork.json_fields & work_type_terms)
      end

      protected

        def json_for_term(term)
          @work.send(term).first
        end

        # Required for WorkFormNameable to function correctly
        def meta_model
          @work.class.name
        end
    end
  end
end
