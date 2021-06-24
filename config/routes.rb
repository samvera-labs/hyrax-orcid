# frozen_string_literal: true

Hyrax::Orcid::Engine.routes.draw do
  scope :dashboard do
    resources :orcid_identity, only: %i[new update destroy], controller: "/hyrax/dashboard/orcid/orcid_identities"
    get "orcid_works/approve/:orcid_id/:work_id", to: "/hyrax/dashboard/orcid/works#approve", as: :orcid_works_approval
  end
end
