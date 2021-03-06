# frozen_string_literal: true

module Hyrax
  module Orcid
    class PublishWorkJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work, identity)
        return unless Flipflop.enabled?(:hyrax_orcid)

        Hyrax::Orcid::Work::PublisherService.new(work, identity).publish
      end
    end
  end
end
