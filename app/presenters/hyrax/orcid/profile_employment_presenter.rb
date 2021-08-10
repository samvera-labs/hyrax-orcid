# frozen_string_literal: true

module Hyrax
  module Orcid
    class ProfileEmploymentPresenter < ProfilePresenter
      def key
        "employment"
      end

      def collection
        @collection.map do |entry|
          {
            title: entry["role-title"],
            items: [
              "#{date_from_hash(entry['start-date'])} - #{date_from_hash(entry['end-date'])}",
              entry["department-name"],
              entry.dig("organization", "name"),
              address_from_hash(entry.dig("organization", "address"))
            ].reject(&:blank?)
          }
        end
      end
    end
  end
end
