# frozen_string_literal: true

RSpec.describe Hyrax::Orcid::UnpublishWorkDelegator do
  let(:delegator) { described_class.new(work) }
  let(:sync_preference) { "sync_all" }
  let(:user) { create(:user) }
  let!(:orcid_identity) { create(:orcid_identity, work_sync_preference: sync_preference, user: user) }
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

  before do
    allow(Hyrax::Orcid::UnpublishWorkJob).to receive(:perform_now).with(work, orcid_identity)

    delegator.perform
  end

  describe "#perform" do
    it "creates a job" do
      expect(Hyrax::Orcid::UnpublishWorkJob).to have_received(:perform_now).with(work, orcid_identity)
    end
  end
end
