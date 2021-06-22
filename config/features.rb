# frozen_string_literal: true

Flipflop.configure do
  feature :orcid_identities,
          default: false,
          description: "Allow users to link their profile to ORCID"
end
