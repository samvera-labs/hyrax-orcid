# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::Configuration do
  context "when overwritten" do
    before do
      Hyrax::Orcid.configure do |config|
        config.bolognese = {
          reader_method: "test_work",
          xml_builder_class_name: "TestWorkBuilder"
        }

        config.client_id = "TEST123"
        config.client_secret = "1234567890"
        config.authorization_redirect_url = "http://testurl.com"
        config.active_job_type = :perform_now
      end
    end

    after do
      Hyrax::Orcid.reset_configuration
    end

    it { expect(Hyrax::Orcid.configuration.bolognese.dig(:reader_method)).to eq "test_work" }
    it { expect(Hyrax::Orcid.configuration.bolognese.dig(:xml_builder_class_name)).to eq "TestWorkBuilder" }
    it { expect(Hyrax::Orcid.configuration.client_id).to eq "TEST123" }
    it { expect(Hyrax::Orcid.configuration.client_secret).to eq "1234567890" }
    it { expect(Hyrax::Orcid.configuration.authorization_redirect_url).to eq "http://testurl.com" }
    it { expect(Hyrax::Orcid.configuration.active_job_type).to eq :perform_now }
  end
end
