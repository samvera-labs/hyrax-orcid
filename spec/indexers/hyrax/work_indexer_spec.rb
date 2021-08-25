# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::WorkIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:name1) { "Stephen Hawking" }
  let(:orcid1) { "https://sandbox.orcid.org/0000-0003-0652-4625" }
  let(:name2) { "Carl Sagan" }
  let(:orcid2) { "0000-0003-0652-4625" }
  let(:name3) { "James Earl Jones" }
  let(:creator) do
    [
      { creator_name: name1, creator_orcid: orcid1 },
      { creator_name: name2, creator_orcid: orcid2 }
    ].to_json
  end
  let(:contributor) do
    [
      { contributor_name: name3, contributor_orcid: "" }
    ].to_json
  end
  let(:work) { create(:work, creator: [creator], contributor: [contributor]) }

  it "indexes the correct fields" do
    expect(solr_document.fetch("creator_display_ssim")).to eq ["#{name1}, #{orcid1}", "#{name2}, #{orcid2}"]
    expect(solr_document.fetch("contributor_display_ssim")).to eq [name3]
  end
end

