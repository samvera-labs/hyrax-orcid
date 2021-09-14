# frozen_string_literal: true

module Hyrax
  module Orcid
    module ActiveJobType
      extend ActiveSupport::Concern

      def active_job_type
        Hyrax::Orcid.configuration.active_job_type 
      end
    end
  end
end
