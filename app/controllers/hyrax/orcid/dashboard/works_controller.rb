# frozen_string_literal: true

module Hyrax
  module Orcid
    module Dashboard
      class WorksController < ::ApplicationController
        def publish
          Hyrax::Orcid::PublishWorkJob.send(action, work, identity)

          respond_to do |f|
            f.html do
              flash[:notice] = I18n.t("orcid_identity.notify.published")
              redirect_back fallback_location: notifications_path
            end
            f.json do
              render json: { success: true }.to_json, status: 200
            end
          end
        end

        def unpublish
          Hyrax::Orcid::UnpublishWorkJob.send(action, work, identity)

          respond_to do |f|
            f.json do
              render json: { success: true }.to_json, status: 200
            end
          end
        end

        protected

        def work
          @_work ||= ActiveFedora::Base.find(permitted_params.dig(:work_id))
        end

        def identity
          @_identity ||= OrcidIdentity.find_by(orcid_id: permitted_params.dig(:orcid_id))
        end

        def permitted_params
          params.permit(:work_id, :orcid_id)
        end

        # TODO: Put this in a configuration object
        def action
          "perform_#{Rails.env.development? ? 'now' : 'later'}"
        end
      end
    end
  end
end
