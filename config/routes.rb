# frozen_string_literal: true

Hyrax::Orcid::Engine.routes.draw do
  scope :dashboard do
    resources :orcid_identity, only: %i[new update destroy], controller: "/hyrax/orcid/dashboard/orcid_identities"

    namespace :orcid_works do
      get "/publish/:orcid_id/:work_id", to: "/hyrax/orcid/dashboard/works#publish", as: :publish
      get "/unpublish/:orcid_id/:work_id", to: "/hyrax/orcid/dashboard/works#unpublish", as: :unpublish
    end
  end

  namespace :users do
    namespace :orcid do
      get "profile/:orcid_id", to: "/hyrax/orcid/users#show", as: :profile
    end
  end
end
