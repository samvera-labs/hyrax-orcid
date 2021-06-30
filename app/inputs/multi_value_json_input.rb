# frozen_string_literal: true

class MultiValueJsonInput < SimpleForm::Inputs::CollectionInput
  # This is required or the multiple values javascript will not be attached to the elements
  def input_type
    "multi_value"
  end

  def subfields
    [:name, :orcid]
  end

  def input(_wrapper_options)
    @rendered_first_element = false

    input_html_classes.unshift('string')

    outer_wrapper do
      buffer_each(collection) do |subfields|
        inner_wrapper do
          inputs = subfields.map do |subfield|
            subfield_name, value = subfield

            input_html_options[:name] = "#{object_name}[#{attribute_name}][][#{subfield_name}]"

            build_field(subfield_name, value)
          end.join("")
        end
      end
    end
  end

  protected

    def outer_wrapper
      <<-HTML
        <ul class="listing">
          #{yield}
        </ul>
      HTML
    end

    def buffer_each(collection)
      collection.each_with_object([]) do |subfields, buffer|
        buffer << yield(subfields)
      end.join("")
    end

    # Returns an Array of hashes
    def collection
      if object.send(attribute_name).reject(&:blank?).blank?
        [subfields.map { |subfield| ["#{attribute_name}_#{subfield}", ""] }.to_h]
      else
        JSON.parse(object.send(attribute_name).first.presence || "[]")
      end
    end

    def inner_wrapper
      <<-HTML
        <li class="field-wrapper">
          #{yield}
        </li>
      HTML
    end

    def build_field(subfield_name, value)
      options = build_field_options(subfield_name, value)

      if options.delete(:type) == 'textarea'
        @builder.text_area(subfield_name, options)
      else
        @builder.text_field(subfield_name, options)
      end
    end

    def build_field_options(subfield_name, value)
      options = input_html_options.dup

      options[:value] = value
      if @rendered_first_element
        options[:id] = nil
        options[:required] = nil
      else
        options[:id] ||= input_dom_id(subfield_name)
      end

      options[:class] ||= []
      options[:class] += ["#{input_dom_id(subfield_name)} form-control multi-text-field multi_value"]
      options[:'aria-labelledby'] = label_id(subfield_name)
      @rendered_first_element = true

      options
    end

    def label_id(subfield_name)
      input_dom_id(subfield_name) + '_label'
    end

    def input_dom_id(subfield_name)
      input_html_options[:id] || "#{object_name}_#{subfield_name}"
    end

    def multiple?
      true
    end
end
