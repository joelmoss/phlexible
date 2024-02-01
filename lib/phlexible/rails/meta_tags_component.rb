# frozen_string_literal: true

module Phlexible
  module Rails
    class MetaTagsComponent < Phlex::HTML
      def template
        controller.instance_variable_get(:@meta_tags)&.each do |name, content|
          meta name: name, content: content.is_a?(String) ? content : content.to_json
        end
      end
    end
  end
end
