# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::Work::ReaderService do
  let(:service) { described_class.new(orcid_identity) }
  let(:user) { create(:user) }
  let!(:orcid_identity) { create(:orcid_identity, work_sync_preference: "sync_all", user: user) }

  let(:response_body) { File.read Rails.root.join("..", "fixtures", "orcid", "json", "orcid_reader_service.json") }
  let(:faraday_response) { instance_double(Faraday::Response, body: JSON.parse(response_body), headers: {}, success?: true) }

  describe "#read" do
    before do
      allow(Faraday).to receive(:send).and_return(faraday_response)
    end

    context "when the request is unsuccessful" do
      let(:faraday_response) { instance_double(Faraday::Response, success?: false) }

      it "returns an empty array" do
        expect(service.read).to be_empty
      end
    end

    context "when the request is successful" do
      it "returns an array of hashes" do
        expect(service.read).to be_a(Array)
        expect(service.read.first).to be_a(Hash)
      end
    end
  end
end


