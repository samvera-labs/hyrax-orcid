# frozen_string_literal: true

module Hyrax
  module Orcid
    module ApiDataHelper
      def api_title(hash)
        hash.dig("title", "title", "value")
      end

      # Format: {"year"=>{"value"=>"1997"}, "month"=>{"value"=>"08"}, "day"=>{"value"=>"20"}}
      def api_date(hash, format = "%Y-%m-%d")
        Date.new(*hash.map { |k,v| v["value"].to_i }).strftime(format)
      end

      # Format: {"city"=>"Cambridge", "region"=>"MA", "country"=>"US"}
      def api_address(hash)
        hash.values.join(", ")
      end

      def api_creators(hash)
        grouped_contributors(hash).dig("AUTHOR")
      end

      def api_contributors(hash)
        grouped_contributors(hash).except("AUTHOR")
      end

      protected

      def grouped_contributors(hash)
        hash.dig("contributors", "contributor").group_by { |c| c.dig("contributor-attributes", "contributor-role") }
      end
    end
  end
end
