class <%= controller_class_name %>::Edit < Perspectives::Base
  input :<%= singular_table_name %>

  output(:show_href) { <%= singular_table_name %>_path(<%= singular_table_name %>) }
  output(:index_href) { <%= plural_table_name %>_path }

  nested 'form', <%= singular_table_name %>: :<%= singular_table_name %>
end
