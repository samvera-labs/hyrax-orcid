# frozen_string_literal: true

module Hyrax
  module Orcid
    module UrlHelper
      include RouteHelper

      ORCID_API_VERSION = "v2.1"

      def orcid_profile_uri(profile_id)
        "https://#{orcid_domain}/#{profile_id}"
      end

      # TODO: Move ENV vars to options panel
      def orcid_authorize_uri
        params = {
          client_id: ENV["ORCID_CLIENT_ID"],
          scope: "/activities/update /read-limited",
          response_type: "code",
          redirect_uri: ENV["ORCID_REDIRECT"]
        }

        "https://#{orcid_domain}/oauth/authorize?#{params.to_query}"
      end

      def orcid_token_uri
        "https://#{orcid_domain}/oauth/token"
      end

      # TODO: Test me
      # Ensure production/dev domains have correct domain
      def orcid_api_uri(orcid_id, endpoint, put_code = nil)
        [
          "https://api.#{orcid_domain}",
          ORCID_API_VERSION,
          orcid_id,
          endpoint,
          put_code
        ].compact.join("/")
      end

      protected

        def orcid_domain
          "#{'sandbox.' unless Rails.env.production?}orcid.org"
        end
    end
  end
end
