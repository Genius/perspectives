class <%= controller_class_name %>::New < Perspectives::Base
  input :<%= singular_table_name %>

  output(:index_href) { <%= plural_table_name %>_path }

  nested 'form', <%= singular_table_name %>: :<%= singular_table_name %>
end
