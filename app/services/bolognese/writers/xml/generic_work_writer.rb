# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Bolognese
  module Writers
    module Xml
      class GenericWorkWriter
        PERMITTED_EXTERNAL_IDENTIFIERS = %w[issn isbn].freeze
        CONTRIBUTOR_MAP = {
          "author" => ["Author"],
          "assignee" => [],
          "editor" => ["Editor"],
          "chair-or-translator" => ["Translator"],
          "co-investigator" => [],
          "co-inventor" => [],
          "graduate-student" => [],
          "other-inventor" => [],
          "principal-investigator" => [],
          "postdoctoral-researcher" => [],
          "support-staff" => ["Other"]
        }.freeze
        DEFAULT_CONTRIBUTOR_ROLE = "support-staff"

        def initialize(xml:, metadata:, type:)
          @xml = xml
          @metadata = metadata
          @type = type
        end

        # Fields guide:
        # https://github.com/ORCID/ORCID-Source/blob/master/orcid-api-web/tutorial/works.md#work-fields
        def build
          @xml[:work].title do
            @xml[:common].title @metadata.write_title.first
            @xml[:common].subtitle @metadata.write_alt_title&.first
          end

          @xml[:work].type @type

          xml_date_published

          # NOTE: A full list of external-id-type: https://pub.orcid.org/v2.1/identifiers
          @xml[:common].send("external-ids") do
            xml_internal_identifier
            xml_external_doi
            xml_external_identifiers
          end

          @xml[:work].contributors do
            xml_creators
            xml_contributors
          end
        end

        protected

          def xml_internal_identifier
            # We should always have a UUID, but specs might not be saving works and will fail otherwise
            return unless @metadata.write_uuid.present?

            @xml[:common].send("external-id") do
              @xml[:common].send("external-id-type", "other-id")
              @xml[:common].send("external-id-value", @metadata.write_uuid)
              @xml[:common].send("external-id-relationship", "self")
            end
          end

          def xml_external_doi
            return if @metadata.meta["doi"].blank?

            @xml[:common].send("external-id") do
              @xml[:common].send("external-id-type", "doi")
              @xml[:common].send("external-id-value", @metadata.doi&.gsub("https://doi.org/", ""))
              @xml[:common].send("external-id-url", @metadata.doi)
              @xml[:common].send("external-id-relationship", "self")
            end
          end

          def xml_external_identifiers
            PERMITTED_EXTERNAL_IDENTIFIERS.each do |item|
              next unless (value = @metadata.meta.dig(item)).present?

              @xml[:common].send("external-id") do
                @xml[:common].send("external-id-type", item)
                @xml[:common].send("external-id-value", value)
                @xml[:common].send("external-id-relationship", "self")
              end
            end
          end

          def xml_creators
            return unless @metadata.creators.present?

            @metadata.creators.each_with_index do |creator, i|
              @xml[:work].contributor do
                xml_contributor_orcid(find_valid_orcid(creator))
                xml_contributor_name("#{creator['givenName']} #{creator['familyName']}")
                xml_contributor_role(i.zero?, "Author")
              end
            end
          end

          def xml_contributors
            return unless @metadata.contributors.present?

            @metadata.contributors.each do |contributor|
              @xml[:work].contributor do
                xml_contributor_orcid(find_valid_orcid(contributor))
                xml_contributor_name("#{contributor['givenName']} #{contributor['familyName']}")
                xml_contributor_role(false, contributor["contributorType"])
              end
            end
          end

          def xml_date_published
            return unless (date = @metadata.date_published&.first).present?

            @xml[:common].send("publication-date") do
              %i[year month day].each do |int|
                @xml[:common].send(int, date.dig("date_published_#{int}"))
              end
            end
          end

        private

          def xml_contributor_name(name)
            @xml[:work].send("credit-name", name)
          end

          def xml_contributor_role(primary = true, role = "Author")
            @xml[:work].send("contributor-attributes") do
              @xml[:work].send("contributor-sequence", primary ? "first" : "additional")

              @xml[:work].send("contributor-role", orcid_role(role))
            end
          end

          def xml_contributor_orcid(orcid)
            return unless orcid.present?

            @xml[:common].send("contributor-orcid") do
              @xml[:common].uri "https://orcid.org/#{orcid}"
              @xml[:common].path orcid
              @xml[:common].host "orcid.org"
            end
          end

          def find_valid_orcid(hsh)
            identifier = hsh["nameIdentifiers"]&.find { |id| id["nameIdentifierScheme"] == "orcid" }

            @metadata.validate_orcid(identifier&.dig("nameIdentifier"))
          end

          def orcid_role(role)
            CONTRIBUTOR_MAP.find { |_k, v| v.include?(role) }&.first || DEFAULT_CONTRIBUTOR_ROLE
          end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
