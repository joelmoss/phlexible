# frozen_string_literal: true

# Generates a form containing a single button that submits to the URL created by the set of options.
# Similar to Rails `button_to` helper.
#
# The form submits a POST request by default. You can specify a different HTTP verb via the :method
# option.
#
# Additional arguments are passed through to the button element, with a few exceptions:
# - :method - Symbol of HTTP verb. Supported verbs are :post, :get, :delete, :patch, and :put.
#   Default is :post.
# - :form_attributes - Hash of HTML attributes to be rendered on the form tag.
# - :form_class - This controls the class of the form within which the submit button will be placed.
#   Default is 'button_to'. @deprecated: use :form_attributes instead if you want to override this.
# - :params - Hash of parameters to be rendered as hidden fields within the form.
module Phlexible
  module Rails
    class ButtonTo < Phlex::HTML
      include ButtonToConcerns
    end
  end
end
