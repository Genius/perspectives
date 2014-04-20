<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  perspectives_actions

  # GET <%= route_url %>
  def index
    respond_with(perspective('<%= plural_table_name %>/index', all_<%= plural_table_name %>: <%= orm_class.all(class_name) %>))
  end

  # GET <%= route_url %>/1
  def show
    respond_with(perspective('<%= plural_table_name %>/show', <%= singular_table_name %>: @<%= singular_table_name %>))
  end

  # GET <%= route_url %>/new
  def new
    respond_with(perspective('<%= plural_table_name %>/new', <%= singular_table_name %>: <%= orm_class.build(class_name) %>))
  end

  # GET <%= route_url %>/1/edit
  def edit
    respond_with(perspective('<%= plural_table_name %>/edit', <%= singular_table_name %>: @<%= singular_table_name %>))
  end

  # POST <%= route_url %>
  def create
    <%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

    if <%= orm_instance.save %>
      respond_to do |format|
        format.html { redirect_to <%= singular_table_name %>, notice: <%= "'#{human_name} was successfully created.'" %> }
        format.json { render json: perspective('<%= plural_table_name %>/show', <%= singular_table_name %>: <%= singular_table_name %>), status: :created, location: <%= singular_table_name %> }
      end
    else
      respond_with(perspective('<%= plural_table_name %>/new', <%= singular_table_name %>: <%= singular_table_name %>))
    end
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
      respond_to do |format|
        format.html { redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully updated.'" %> }
        format.json { render json: perspective('<%= plural_table_name %>/show', <%= singular_table_name %>: @<%= singular_table_name %>) }
      end
    else
      respond_with(perspective('<%= plural_table_name %>/edit', <%= singular_table_name %>: @<%= singular_table_name %>))
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully destroyed.'" %>
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    # Only allow a trusted parameter "white list" through.
    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[<%= ":#{singular_table_name}" %>]
      <%- else -%>
      params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end
<% end -%>
