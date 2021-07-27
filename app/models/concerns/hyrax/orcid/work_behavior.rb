# frozen_string_literal: true

module Hyrax
  module Orcid
    module WorkBehavior
      extend ActiveSupport::Concern

      included do
        class_attribute :json_fields
        self.json_fields = %i[creator contributor]
      end
    end
  end
end
