# frozen_string_literal: true

module Hyrax
  module Orcid
    module GenericWorkFormBehavior
      extend ActiveSupport::Concern

      class_methods do
        def build_permitted_params
          super.tap do |permitted_params|
            permitted_params << creator_fields
          end
        end

        def creator_fields
          {
            creator: [:creator_name, :creator_orcid]
          }
        end
      end
    end
  end
end
