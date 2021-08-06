# frozen_string_literal: true

module Hyrax
  module Orcid
    class UsersController < ApplicationController
      def show
        render "show", layout: false
      end

      def orcid_identity
        @_user_identity ||= OrcidIdentity.find_by(orcid_id: orcid_id)
      end
      helper_method :orcid_identity

      protected

      def orcid_id
        params.require(:orcid_id)
      end
    end
  end
end
