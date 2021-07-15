# frozen_string_literal: true

# TODO: Remove when PR merged - https://github.com/datacite/bolognese/pull/121
module Bolognese
  module UtilsBehaviors
    extend ActiveSupport::Concern

    def validate_orcid(orcid)
      orcid = Array(/\A(?:(?:http|https):\/\/(?:(?:www|sandbox)?\.)?orcid\.org\/)?(\d{4}[[:space:]-]\d{4}[[:space:]-]\d{4}[[:space:]-]\d{3}[0-9X]+)\z/.match(orcid)).last
      orcid.gsub(/[[:space:]]/, "-") if orcid.present?
    end
  end
end
