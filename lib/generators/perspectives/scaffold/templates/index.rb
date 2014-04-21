class <%= controller_class_name %>::Index < Perspectives::Base
  input :all_<%= plural_table_name %>

  output(:new_href) { new_<%= singular_table_name %>_path }

  nested_collection '<%= plural_table_name %>/tiny',
    collection: proc { all_<%= plural_table_name %> },
    output: :<%= plural_table_name %>
end
