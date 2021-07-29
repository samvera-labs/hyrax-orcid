# frozen_string_literal: true

Hyrax::Orcid::Engine.routes.draw do
  scope :dashboard do
    resources :orcid_identity, only: %i[new update destroy], controller: "/hyrax/dashboard/orcid/orcid_identities"

    namespace :orcid_works do
      get "/publish/:orcid_id/:work_id", to: "/hyrax/dashboard/orcid/works#publish", as: :publish
      get "/unpublish/:orcid_id/:work_id", to: "/hyrax/dashboard/orcid/works#unpublish", as: :unpublish
    end
  end
end
