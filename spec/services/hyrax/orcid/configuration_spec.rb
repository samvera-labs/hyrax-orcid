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
  end
end
