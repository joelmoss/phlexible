# frozen_string_literal: true

module Phlexible
  module Rails
    module ActionController
      module MetaTags
        extend ActiveSupport::Concern

        def meta_tags
          @meta_tags ||= {}
        end

        def meta_tag(name, content)
          meta_tags[name] = content
        end

        module ClassMethods
          def meta_tag(name, content, **kwargs)
            before_action(**kwargs) do |ctrl|
              ctrl.meta_tag name, content.is_a?(Proc) ? ctrl.instance_exec(&content) : content
            end
          end
        end
      end
    end
  end
end
