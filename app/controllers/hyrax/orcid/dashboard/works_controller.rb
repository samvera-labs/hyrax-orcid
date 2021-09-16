# frozen_string_literal: true

module Hyrax
  module Orcid
    module Dashboard
      class WorksController < ::ApplicationController
        include Hyrax::Orcid::ActiveJobType

        def publish
          Hyrax::Orcid::PublishWorkJob.send(active_job_type, work, identity)

          respond_to do |f|
            f.html do
              flash[:notice] = I18n.t("hyrax.orcid.notify.published")
              redirect_back fallback_location: notifications_path
            end
            f.json do
              render json: { success: true }.to_json, status: 200
            end
          end
        end

        def unpublish
          Hyrax::Orcid::UnpublishWorkJob.send(active_job_type, work, identity)

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
      end
    end
  end
end
