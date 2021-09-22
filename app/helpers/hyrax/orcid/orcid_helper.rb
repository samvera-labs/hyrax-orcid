# frozen_string_literal: true

module Hyrax
  module Orcid
    module OrcidHelper
      ORCID_REGEX = %r{
        (?:(?:http|https):\/\/
        (?:www\.(?:sandbox\.)?)?orcid\.org\/)?
        (\d{4}[[:space:]-]\d{4}[[:space:]-]\d{4}[[:space:]-]\d{3}[0-9X]+)
      }x

      def validate_orcid(orcid)
        return if orcid.blank?

        # Ensure we only return the last match, which should be the Orcid ID
        orcid = Array.wrap(orcid.match(ORCID_REGEX).to_a).last

        orcid.to_s.gsub(/[[:space:]]/, "-") if orcid.present?
      end
    end
  end
end
