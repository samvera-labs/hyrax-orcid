# frozen_string_literal: true

Flipflop.configure do
  feature :hyrax_orcid,
          default: false,
          description: "Allow users to link their profile to ORCID"
end
