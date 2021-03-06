# frozen_string_literal: true
module Hyrax
  module Actors
    module Orcid
      class JSONFieldsActor < Hyrax::Actors::AbstractActor
        def create(env)
          jsonify_fields(env) && next_actor.create(env)
        end

        def update(env)
          jsonify_fields(env) && next_actor.update(env)
        end

        private

          # rubocop:disable Metrics/AbcSize
          def jsonify_fields(env)
            env.curation_concern.class.json_fields.each do |field|
              if name_blank?(field, env.attributes[field]) || recursive_blank?(env.attributes[field])
                env.attributes.delete(field)
              else
                env.attributes[field].reject! { |o| name_blank?(field, o) || recursive_blank?(o) } if env.attributes[field].is_a? Array
                env.attributes[field] = env.attributes[field].to_json
              end
              env.attributes[field] = Array(env.attributes[field]) if env.curation_concern.class.multiple?(field)
            end
          end
          # rubocop:enable Metrics/AbcSize

          def name_blank?(field, obj)
            return false unless field.in? GenericWork.json_fields

            recursive_blank?(Array(obj).map { |o| o.reject { |k, _v| k == "#{field}_name_type" } })
          end

          def recursive_blank?(obj)
            case obj
            when Hash
              obj.values.all? { |o| recursive_blank?(o) }
            when Array
              obj.all? { |o| recursive_blank?(o) }
            else
              obj.blank?
            end
          end
      end
    end
  end
end
