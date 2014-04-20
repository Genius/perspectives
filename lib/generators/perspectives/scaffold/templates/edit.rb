class <%= controller_class_name %>::Edit < Perspectives::Base
  param :<%= singular_table_name %>

  property(:show_href) { <%= singular_table_name %>_path(<%= singular_table_name %>) }
  property(:index_href) { <%= plural_table_name %>_path }

  nested 'form', <%= singular_table_name %>: :<%= singular_table_name %>
end
