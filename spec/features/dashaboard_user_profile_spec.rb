# frozen_string_literal: true

require "rails_helper"

# FIXME: Need to figure out how to get the selenium chrome driver working
RSpec.describe "The Dashboard User Profile Page", type: :feature, js: true do
  let(:user) { create(:admin) }
  let(:code) { "123456" }
  let(:orcid_id) { "0000-0003-0652-1234" }
  let(:access_token) { "292b3a63-1259-44bf-a0f8-11bf15134920" }

  before do
    WebMock.enable!

    allow_any_instance_of(Ability).to receive(:admin_set_with_deposit?).and_return(true)
    allow_any_instance_of(Ability).to receive(:can?).and_call_original
    allow_any_instance_of(Ability).to receive(:can?).with(:new, anything).and_return(true)

    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(true)

    sign_in user
  end

  describe "when the feature is disabled" do
    before do
      allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(false)

      visit hyrax.dashboard_profile_path(user.to_param, locale: "en")
    end

    it "does not display the authorize link" do
      expect(page).not_to have_link("Connect to ORCID")
    end
  end

  describe "when the user has not linked their account" do
    before do
      visit hyrax.dashboard_profile_path(user.to_param, locale: "en")
    end

    it "displays the authorize link" do
      expect(page).to have_link("Connect to ORCID")
      expect(find_link("Connect to ORCID")[:href]).to include("https://sandbox.orcid.org/oauth/authorize")
    end
  end

  describe "when the user is returning from the ORCID authorization endpoint" do
    let(:response_body) do
      {
        "access_token": access_token,
        "token_type": "bearer",
        "refresh_token": "55a45c88-59d7-4646-b30e-836b3dead62c",
        "expires_in": 631138518,
        "scope": "/read-limited /activities/update",
        "name": "Johnny Testing" ,
        "orcid": orcid_id
      }.to_json
    end
    let(:faraday_response) { instance_double(Faraday::Response, body: response_body, headers: {}, success?: true) }

    before do
      stub_request(:post, "https://sandbox.orcid.org/oauth/token")
        .with(
          body: {
            "client_id": "APP-IK56X6QNRRL9VNOM",
            "client_secret": "f5154480-039b-4ad5-aaf4-aa6eb272c670",
            "code": code,
            "grant_type": "authorization_code"
          },
          headers: {
            "Accept": "application/json",
            "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "Faraday v0.17.4"
          }
        )
        .to_return(status: 200, body: response_body, headers: {})

      visit Hyrax::Orcid::Engine.routes.url_helpers.new_orcid_identity_path(code: code)
    end

    it "redirects back to the users profile" do
      expect(page).to have_current_path(hyrax.dashboard_profile_path(user.to_param, locale: "en"))
    end

    it "shows the correct information" do
      expect(page).to have_content(orcid_id)
      expect(page).to have_content(user.name)
      expect(page).not_to have_link("Connect to ORCID")
    end

    it "creates the orcid identity for the current user" do
      expect(user.orcid_identity).to be_present
      expect(user.orcid_identity.access_token).to eq(access_token)
      expect(user.orcid_identity.orcid_id).to eq(orcid_id)
    end
  end

  describe "when the user has linked their account" do
    let(:user) { create(:user) }
    let(:orcid_identity) { create(:orcid_identity, work_sync_preference: sync_preference, user: user) }
    let(:sync_preference) { "sync_all" }

    before do
      orcid_identity

      visit hyrax.dashboard_profile_path(user.to_param, locale: "en")
    end

    it "displays the options panel" do
      expect(page).to have_content(orcid_identity.orcid_id)
      expect(page).to have_content(user.name)
      expect(page).not_to have_link("Connect to ORCID")
    end
  end
end
