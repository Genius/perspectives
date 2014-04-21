module Perspectives::Forms
  class TextField < Base
    input :object, :field

    output(:param_key) { object.class.model_name.param_key }
    output(:human_name) { object.class.name.humanize }
    output(:field_id) { "#{param_key}_#{field}" }
    output(:field_param) do
      "#{param_key}[#{field.sub(/\?$/, '')}]"
    end

    output(:name) { object.class.human_attribute_name(field) }
    output(:value) { object.__send__(field) }
  end
end
