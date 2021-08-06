# frozen_string_literal: true

module Hyrax
  module Orcid
    module ApiDataHelper
      # Format: {"year"=>{"value"=>"1997"}, "month"=>{"value"=>"08"}, "day"=>{"value"=>"20"}}
      def api_date(hash, format = "%Y-%m-%d")
        Date.new(*hash.map { |k,v| v["value"].to_i }).strftime(format)
      end

      # Format: {"city"=>"Cambridge", "region"=>"MA", "country"=>"US"}
      def api_address(hash)
        hash.values.join(", ")
      end
    end
  end
end
