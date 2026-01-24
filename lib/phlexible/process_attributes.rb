# frozen_string_literal: true

# rubocop:disable Style/DocumentDynamicEvalDefinition
module Phlexible::ProcessAttributes
  if Phlex::VERSION >= '2.0.0'
    def register_element(method_name, tag: method_name.name.tr('_', '-'))
      super

      wrapper = Module.new do
        define_method(method_name) do |**attributes, &block|
          attributes = process_attributes(attributes) if respond_to?(:process_attributes)
          super(**attributes, &block)
        end
      end
      prepend wrapper
    end

    module StandardElements
      Phlex::HTML::StandardElements.public_instance_methods(false).each do |element|
        class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          # frozen_string_literal: true

          def #{element}(**attributes, &content)
            attributes = process_attributes(attributes) if respond_to?(:process_attributes)
            super(**attributes, &content)
          end
        RUBY
      end
    end

    module VoidElements
      Phlex::HTML::VoidElements.public_instance_methods(false).each do |element|
        class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          # frozen_string_literal: true

          def #{element}(**attributes)
            attributes = process_attributes(attributes) if respond_to?(:process_attributes)
            super(**attributes)
          end
        RUBY
      end
    end
  end
end
# rubocop:enable Style/DocumentDynamicEvalDefinition

# rubocop:disable Rails/NegateInclude
if Phlex::VERSION >= '2.0.0'
  if !Phlex::HTML::StandardElements.include?(Phlexible::ProcessAttributes::StandardElements)
    Phlex::HTML::StandardElements.prepend Phlexible::ProcessAttributes::StandardElements
  end
  if !Phlex::HTML::VoidElements.include?(Phlexible::ProcessAttributes::VoidElements)
    Phlex::HTML::VoidElements.prepend Phlexible::ProcessAttributes::VoidElements
  end
end
# rubocop:enable Rails/NegateInclude
