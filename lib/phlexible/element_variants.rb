# frozen_string_literal: true

module Phlexible
  #
  # Provides variant support, allowing you to customise attributes based on the variant name.
  # Declare the variant for one or more tags:
  #
  #   variant :external, on: :a
  #   variant :divider, on: [:h1, :h2, :h3, :h4, :h5, :h6]
  #
  # Then pass the variant name as a Symbol or Array of Symbols in the first argument to the element
  # method.
  #
  #   h1(:divider) { 'My Title' }
  #
  # The variant will be applied to the element, which by default will simply add a data attribute to
  # the element:
  #
  #   <h1 data-variant-divider></h1>
  #
  # Optionally, you can pass a block to the declaration, and the when the variant is used, the block
  # will be called with the attributes Hash. Allowing you to modify the attributes.
  #
  #   variant :external, on: :a do |attributes|
  #     attributes[:target] = '_blank'
  #   end
  #
  module ElementVariants
    ELEMENT_VARIANTS = Concurrent::Map.new

    def variant(name, on:, &block)
      on = [on] if !on.is_a?(Array)

      on.each do |tag_name|
        tag_name = tag_name.to_s.tr('-', '_').to_sym

        class_eval(<<-RUBY, __FILE__, __LINE__ + 1) # rubocop:disable Style/DocumentDynamicEvalDefinition
          # frozen_string_literal: true

          def #{tag_name}(*variants, **attributes, &block)    # def h4(...)
            attributes[:data] = attributes.fetch(:data, {})
            rvars = ELEMENT_VARIANTS[:#{tag_name}]

            variants.each do |variant|
              unless rvars[variant]
                raise ArgumentError, "Unknown variant `\#{variant}` for `#{tag_name}`. Have you registered it?"
              end

              attributes[:data]["variant-" + variant.to_s.tr('_', '-')] = true

              if rvars[variant].is_a?(Proc)
                instance_exec(attributes, &rvars[variant])
              end
            end

            super(**attributes, &block)
          end
        RUBY

        ELEMENT_VARIANTS[tag_name] = Concurrent::Map.new if !ELEMENT_VARIANTS[tag_name]
        ELEMENT_VARIANTS[tag_name][name] = block || true if !ELEMENT_VARIANTS[tag_name][name]
      end
    end
  end
end
