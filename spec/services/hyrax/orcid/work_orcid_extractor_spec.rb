# frozen_string_literal: true

RSpec.describe Hyrax::Orcid::WorkOrcidExtractor do
  let(:user) { create(:user) }
  let!(:orcid_identity) { create(:orcid_identity, work_sync_preference: sync_preference, user: user) }
  let(:sync_preference) { "sync_all" }
  let(:service) { described_class.new(work) }
  let(:work) { create(:work, user: user, **work_attributes) }
  let(:work_attributes) do
    {
      "title" => ["Moomin"],
      "creator" => [
        [{
          "creator_name" => "John Smith",
          "creator_orcid" => orcid_id
        }].to_json
      ]
    }
  end
  let(:orcid_id) { user.orcid_identity.orcid_id }
  let(:orcid_id2) { "0000-1111-2222-3333" }

  describe "#extract" do
    it "returns an array" do
      expect(service.extract).to be_a(Array)
    end

    it "includes the orcid_id" do
      expect(service.extract).to include(orcid_id)
    end

    context "when there are multiple creators" do
      let(:work_attributes) do
        {
          "title" => ["Moomin"],
          "creator" => [
            [{
              "creator_name" => "John Smith",
              "creator_orcid" => orcid_id
            }, {
              "creator_name" => "Johna Smithison",
              "creator_orcid" => orcid_id2
            }].to_json
          ]
        }
      end

      it "includes both the orcid_id" do
        expect(service.extract).to include(orcid_id, orcid_id2)
      end
    end
  end

  describe "#target_terms" do
    it "is an array of symbols" do
      expect(service.target_terms).to be_a(Array)
      expect(service.target_terms.all? { |val| val.is_a?(Symbol) }).to be_truthy
    end
  end
end
