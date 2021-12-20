# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::IdentityStrategyDelegator do
  let(:service) { described_class.new(work) }
  let(:user) { create(:user) }
  let!(:orcid_identity) { create(:orcid_identity, work_sync_preference: work_sync_preference, user: user) }
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
  let(:orcid_id) do
    orcid_identity # Ensure the association has been created

    user.orcid_identity.orcid_id
  end
  let(:work_sync_preference) { "sync_all" }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:hyrax_orcid).and_return(true)
    allow(Hyrax::Orcid.configuration).to receive(:active_job_type).and_return(:perform_later)
    ActiveJob::Base.queue_adapter = :test
  end

  describe ".new" do
    context "when arguments are used" do
      it "doesn't raise" do
        expect { described_class.new(work) }.not_to raise_error
      end
    end

    context "when invalid type is used" do
      let(:work) { "foo" }

      it "raises" do
        expect { described_class.new(work) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#perform" do
    before do
      allow(service).to receive(:perform_user_strategy).and_call_original
    end

    context "when the feature is enabled" do
      it "calls the delegated sync class" do
        service.perform

        expect(service).to have_received(:perform_user_strategy).with(orcid_id)
      end
    end

    context "when the feature is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:hyrax_orcid).and_return(false)
      end

      it "returns nil" do
        expect(service).not_to have_received(:perform_user_strategy).with(orcid_id)
      end
    end
  end

  describe "#perform_user_strategy" do
    it "calls the perform method on the sync class" do
      expect { service.send(:perform_user_strategy, orcid_id) }
        .to have_enqueued_job(Hyrax::Orcid::PerformIdentityStrategyJob)
        .on_queue(Hyrax.config.ingest_queue_name)
        .with(work, orcid_identity)
    end
  end
end
