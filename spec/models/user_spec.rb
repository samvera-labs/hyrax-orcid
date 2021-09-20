# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  it { is_expected.to have_one(:orcid_identity) }

  describe "#orcid_identity?" do
    context "when the user has not authorized with ORCID" do
      it "is false" do
        expect(user.orcid_identity?).to be_falsey
      end
    end

    context "when the association is found on the user" do
      subject(:user) { create(:user, :with_orcid_identity) }

      it "is true" do
        expect(user.orcid_identity?).to be_truthy
      end
    end
  end

  describe "#orcid_referenced_works" do
    subject(:user) { create(:user, :with_orcid_identity) }

    let(:title) { "Moomin" }
    let(:description) { "Swedish comic about the adventures of the residents of Moominvalley." }
    let(:keyword) { "Lighthouses" }
    let(:resource_type) { "Book" }
    let(:creator1_first_name) { "Sebastian" }
    let(:creator1_last_name) { "Hageneuer" }
    let(:creator1_orcid) { "0000-1234-5109-5291" }
    let(:creator1) do
      {
        "creator_name" => "#{creator1_first_name} #{creator1_last_name}",
        "creator_orcid" => "https://orcid.org/#{creator1_orcid}"
      }
    end
    let(:creator2_first_name) { "Johnny" }
    let(:creator2_last_name) { "Testing" }
    let(:creator2_orcid) { "0000-0001-5109-3701" }
    let(:creator2) do
      {
        "creator_name" => "#{creator2_first_name} #{creator2_last_name}",
        "creator_orcid" => "https://orcid.org/#{creator2_orcid}"
      }
    end
    let(:contributor1_first_name) { "Jannet" }
    let(:contributor1_last_name) { "Gnitset" }
    let(:contributor1_orcid) { "0000-1234-5109-3702" }
    let(:contributor1_role) { "Other" }
    let(:contributor1) do
      {
        "contributor_name" => "#{contributor1_first_name} #{contributor1_last_name}",
        "contributor_orcid" => "https://orcid.org/#{contributor1_orcid}",
      }
    end
    let(:work1_attributes) do
      {
        title: [title],
        resource_type: [resource_type],
        creator: [[creator1, creator2].to_json],
        contributor: [[contributor1].to_json],
        description: [description],
        keyword: [keyword],
        visibility: "open"
      }
    end
    let(:work2_attributes) do
      {
        visibility: "open"
      }
    end
    let(:work1) { create(:work, work1_attributes) }
    let(:work2) { create(:work, work2_attributes) }

    before do
      ActiveFedora::SolrService.add(work1.to_solr)
      ActiveFedora::SolrService.add(work2.to_solr)

      ActiveFedora::SolrService.commit
    end

    context "when the users orcid ID is not referenced" do
      it "doesn't return the work" do
        expect(user.orcid_referenced_works.count).to be(0)
      end
    end

    context "when the users orcid ID is referenced" do
      let(:creator1_orcid) { user.orcid_identity.orcid_id }

      it "returns the correct documents" do
        expect(user.orcid_referenced_works.count).to be(1)
        expect(user.orcid_referenced_works.first["id"]).to eq(work1.id)
        expect(user.orcid_referenced_works.map { |work| work["id"] }).not_to include(work2.id)
      end
    end

    context "when the user is referenced in multiple work" do
      let(:creator1_orcid) { user.orcid_identity.orcid_id }
      let(:work2_attributes) do
        {
          visibility: "open",
          creator: [[creator1].to_json]
        }
      end

      it "returns the correct documents" do
        expect(user.orcid_referenced_works.count).to be(2)

        ids = user.orcid_referenced_works.map { |work| work["id"] }
        expect(ids).to include(work1.id)
        expect(ids).to include(work2.id)
      end
    end

    context "when the users orcid ID is referenced as a contributor" do
      let(:contributor1_orcid) { user.orcid_identity.orcid_id }

      it "returns the correct documents" do
        expect(user.orcid_referenced_works.count).to be(1)
        expect(user.orcid_referenced_works.first["id"]).to eq(work1.id)
        expect(user.orcid_referenced_works.map { |work| work["id"] }).not_to include(work2.id)
      end
    end
  end
end
