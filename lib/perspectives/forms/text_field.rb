module Perspectives::Forms
  class TextField < Base
    param :object, :field

    property(:param_key) { object.class.model_name.param_key }
    property(:human_name) { object.class.name.humanize }
    property(:field_id) { "#{param_key}_#{field}" }
    property(:field_param) do
      "#{param_key}[#{field.sub(/\?$/, '')}]"
    end

    property(:name) { object.class.human_attribute_name(field) }
    property(:value) { object.__send__(field) }
  end
end
