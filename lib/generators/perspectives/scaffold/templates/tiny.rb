class <%= controller_class_name %>::Tiny < Perspectives::Base
  input :<%= singular_table_name %>

  delegate_output <%= attributes.map { |a| ":#{a.name}" }.join(', ') %>, to: :<%= singular_table_name %>

  output(:show_href) { <%= singular_table_name %>_path(<%= singular_table_name %>) }
  output(:edit_href) { edit_<%= singular_table_name %>_path(<%= singular_table_name %>) }
end
