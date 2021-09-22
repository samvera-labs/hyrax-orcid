# frozen_string_literal: true

module Hyrax
  module Orcid
    module Blacklight
      module Rendering
        class PipelineJsonExtractor < ::Blacklight::Rendering::AbstractStep
          def render
            # FIXME: `GenericWork.json_fields` could be a configuration option
            val = GenericWork.json_fields.include?(config.itemprop&.to_sym) ? parsed_values : values

            next_step(val)
          end

          protected

            def parsed_values
              JSON.parse(values.first).pluck("#{config.itemprop}_name")
            end
        end
      end
    end
  end
end
