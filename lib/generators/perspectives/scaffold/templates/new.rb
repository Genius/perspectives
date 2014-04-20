class <%= controller_class_name %>::New < Perspectives::Base
  param :<%= singular_table_name %>

  property(:index_href) { <%= plural_table_name %>_path }

  nested 'form', <%= singular_table_name %>: :<%= singular_table_name %>
end
