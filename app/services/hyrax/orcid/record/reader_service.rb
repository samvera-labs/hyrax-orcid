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

        def read_peer_reviews
          response.dig("peer-reviews", "group")
        end

        def read_works
          res = Faraday.send(:get, request_url(type: :works, put_code: work_codes.join(",")), nil, headers)

          return {} unless res.success?

          JSON.parse(res.body).dig("bulk")
        end

        protected

        def response
          @_response ||= begin
            response = Faraday.send(:get, request_url, nil, headers)

            return {} unless response.success?

            JSON.parse(response.body).dig("activities-summary")
          end
        end

        def request_url(type: :record, put_code: nil)
          orcid_api_uri(@identity.orcid_id, type, put_code)
        end

        def headers
          {
            "authorization" => "Bearer #{@identity.access_token}",
            "Content-Type" => "application/json"
          }
        end

        def work_codes
          response.dig("works", "group").map { |hsh| hsh.dig("work-summary").first.dig("put-code") }
        end
      end
    end
  end
end

