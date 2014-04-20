class <%= controller_class_name %>::Index < Perspectives::Base
  param :all_<%= plural_table_name %>

  property(:new_href) { :new_<%= singular_table_name %>_path }

  nested_collection '<%= plural_table_name %>/tiny',
    collection: proc { all_<%= plural_table_name %> },
    property: :<%= plural_table_name %>
end
