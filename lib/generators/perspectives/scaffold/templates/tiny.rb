class <%= controller_class_name %>::Tiny < Perspectives::Base
  param :<%= singular_table_name %>

  delegate_property <%= attributes.map { |a| ":#{a.name}" }.join(', ') %>, to: :<%= singular_table_name %>

  property(:show_href) { <%= singular_table_name %>_path(<%= singular_table_name %>) }
  property(:edit_href) { edit_<%= singular_table_name %>_path(<%= singular_table_name %>) }
end
