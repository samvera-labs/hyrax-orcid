# frozen_string_literal: true

module Hyrax
  module Orcid
    module Work
      class ReaderService
        include Hyrax::Orcid::UrlHelper

        def initialize(identity)
          @identity = identity
        end

        def read
          @response = Faraday.send(:get, request_url, nil, headers)

          return [] unless @response.success?

          JSON.parse(@response.body).dig("group")
        end

        protected

        def request_url
          orcid_api_uri(@identity.orcid_id, :works)
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

