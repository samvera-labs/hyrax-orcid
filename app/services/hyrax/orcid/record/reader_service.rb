# frozen_string_literal: true

module Hyrax
  module Orcid
    module Record
      class ReaderService
        include Hyrax::Orcid::UrlHelper

        def initialize(identity)
          @identity = identity
        end

        def read_education
          response.dig("educations", "education-summary")
        end

        def read_employment
          response.dig("employments", "employment-summary")
        end

        def read_funding
          response.dig("fundings", "group")
        end

        def read_peer_review
          response.dig("peer-reviews", "group")
        end

        protected

        def response
          @_response ||= begin
            response = Faraday.send(:get, request_url, nil, headers)

            return {} unless response.success?

            JSON.parse(response.body).dig("activities-summary")
          end
        end

        def request_url
          orcid_api_uri(@identity.orcid_id, :record)
        end

        def headers
          {
            "authorization" => "Bearer #{@identity.access_token}",
            "Content-Type" => "application/json"
          }
        end
      end
    end
  end
end

