# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::Configuration do
  let(:client_id) { "TEST123" }
  let(:client_secret) { "1234567890" }
  let(:redirect_url) { "http://testurl.com" }
  let(:reader_method) { "test_work" }
  let(:builder_class_name) { "TestWorkBuilder" }
  let(:active_job_type) { :perform_now }
  let(:environment) { :production }
  let(:hyrax_json_actor) { nil }
  let(:blacklight_pipeline_actor) { nil }
  let(:work_types) { ["TestForm"] }
  let(:presenter_behavior) { "TestPresenterBehavior" }

  context "when overwritten" do
    before do
      Hyrax::Orcid.configure do |config|
        config.bolognese = {
          reader_method: reader_method,
          xml_builder_class_name: builder_class_name
        }

        config.auth = {
          client_id: client_id,
          client_secret: client_secret,
          redirect_url: redirect_url
        }

        config.environment = environment
        config.active_job_type = active_job_type
        config.hyrax_json_actor = hyrax_json_actor
        config.blacklight_pipeline_actor = blacklight_pipeline_actor
        config.work_types = work_types
        config.presenter_behavior = presenter_behavior
      end
    end

    after do
      Hyrax::Orcid.reset_configuration
    end

    it { expect(Hyrax::Orcid.configuration.auth[:client_id]).to eq client_id }
    it { expect(Hyrax::Orcid.configuration.auth[:client_secret]).to eq client_secret }
    it { expect(Hyrax::Orcid.configuration.auth[:redirect_url]).to eq redirect_url }
    it { expect(Hyrax::Orcid.configuration.bolognese[:reader_method]).to eq reader_method }
    it { expect(Hyrax::Orcid.configuration.bolognese[:xml_builder_class_name]).to eq builder_class_name }
    it { expect(Hyrax::Orcid.configuration.environment).to eq environment }
    it { expect(Hyrax::Orcid.configuration.active_job_type).to eq active_job_type }
    it { expect(Hyrax::Orcid.configuration.hyrax_json_actor).to be_nil }
    it { expect(Hyrax::Orcid.configuration.blacklight_pipeline_actor).to be_nil }
    it { expect(Hyrax::Orcid.configuration.work_types).to eq work_types }
    it { expect(Hyrax::Orcid.configuration.presenter_behavior).to eq presenter_behavior }
  end
end
