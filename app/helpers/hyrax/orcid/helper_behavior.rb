# frozen_string_literal: true

module Hyrax
  module Orcid
    module HelperBehavior
      include Hyrax::Orcid::UrlHelper
      include Hyrax::Orcid::OrcidHelper
      include Hyrax::Orcid::WorkHelper
    end
  end
end
