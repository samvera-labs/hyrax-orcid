# frozen_string_literal: true

module Hyrax
  module Orcid
    module OrcidHelper
      # Originally taken from Bolognese, however theirs doesn't account for no space/- delimiter.
      #
      # The Orcid reference is incomplete and can have variations on the structure set out here:
      # https://support.orcid.org/hc/en-us/articles/360006897674-Structure-of-the-ORCID-Identifier
      #
      # The following could also be given:
      # 000000029079593X
      # 0000 0002 9079 593X
      # 0000-0002-9079-593X - note the X here
      # 0000-1234-1234-1234
      ORCID_REGEX = %r{
        (?:(?:http|https):\/\/
        (?:www\.(?:sandbox\.)?)?orcid\.org\/)?
        (\d{4}[[:space:]-]?\d{4}[[:space:]-]?\d{4}[[:space:]-]?(\d{3}X|\d{4}))
      }x

      def validate_orcid(orcid)
        return if orcid.blank?

        # [0] full match
        # [1] only the orcid ID - the one we want
        # [2] last 4 digits
        orcid = Array.wrap(orcid.match(ORCID_REGEX).to_a).second

        return if orcid.blank?

        # If we have a valid Orcid ID, remove anything that isn't a number or an X, group into 4's and hyphen delimit
        orcid.gsub(/[^\dX]/, "").scan(/.{1,4}/).join("-")
      end
    end
  end
end
