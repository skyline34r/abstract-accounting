module RolesHelper

  include JqgridsHelper

  def roles_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/roles',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['name', 'id'],
      :colModel => [
        { :name => 'name',  :index => 'name',   :width => 800 },
        { :name => 'id',    :index => 'id',     :width => 5, :hidden => true }
      ],
      :pager => '#roles_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'name',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'roles_list', grid, options

  end

end
