class <%= controller_class_name %>::Form < Perspectives::Base
  param :<%= singular_table_name %>

  property(:submit_to) do
    <%= singular_table_name %>.new_record? ? <%= plural_table_name %>_path : <%= singular_table_name %>_path(<%= singular_table_name %>)
  end

  property(:submit_method) { !<%= singular_table_name %>.new_record? && 'patch' }

  property(:errors) do
    errors = <%= singular_table_name %>.errors
    if errors.any?
      {
        error_count: errors.count,
        name: <%= singular_table_name %>.class.human_name,
        error_messages: object.errors.full_messages.map { |msg| {msg: msg } }
      }
    end
  end
end
