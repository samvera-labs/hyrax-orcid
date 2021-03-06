# frozen_string_literal: true

module Hyrax
  module Orcid
    class UnpublishWorkDelegatorJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work)
        return unless Flipflop.enabled?(:hyrax_orcid)

        Hyrax::Orcid::UnpublishWorkDelegator.new(work).perform
      end
    end
  end
end
