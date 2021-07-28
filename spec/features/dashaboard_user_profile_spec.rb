# frozen_string_literal: true

require "rails_helper"

# FIXME: Need to figure out how to get the selenium chrome driver working
# RSpec.describe "The Dashboard User Profile Page", type: :feature, js: true do
#   let(:user) { create(:admin) }

#   before do
#     allow_any_instance_of(Ability).to receive(:admin_set_with_deposit?).and_return(true)
#     allow_any_instance_of(Ability).to receive(:can?).and_call_original
#     allow_any_instance_of(Ability).to receive(:can?).with(:new, anything).and_return(true)

#     sign_in user
#   end

#   context "when the user has not linked their account" do
#     scenario "it displays" do
#       visit "/dashboard"
#       click_on "Your activity"
#       click_on "Profile"

#       page.save_screenshot(full: true)
#     end
#     # expect(page).to have_field('generic_work_keyword', with: 'metadata')
#   end

#   context "when the user has linked their account" do

#   end
# end
