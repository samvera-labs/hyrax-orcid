# frozen_string_literal: true

module Bolognese
  module Writers
    module Orcid
      module XmlWriter
        # NOTE: I really don't like having to have the put_code injected here, but
        # we need to pass it in from the orcid_work instance somehow and this is the
        # best solution I have right now
        def orcid_xml(type, put_code = nil)
          root_attributes = {
            "xmlns:common" => "http://www.orcid.org/ns/common",
            "xmlns:work" => "http://www.orcid.org/ns/work",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-2.1.xsd "
          }
          # If we are updating, we need to add a put-code in the root attributes
          root_attributes["put-code"] = put_code if put_code.present?

          builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml.work(root_attributes) do
              # Hack to enable root level namespaces `work:work`
              xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

              xml_writer_class.new(xml: xml, type: type, metadata: self).build
            end
          end

          builder.to_xml
        end

        # Override this class if you wish to have more specific writers
        def xml_writer_class
          Bolognese::Writers::Xml::WorkWriter
        end
      end
    end
  end
end
