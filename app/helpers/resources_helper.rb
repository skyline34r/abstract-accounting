module ResourcesHelper

  include JqgridsHelper

  def resources_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/resources',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'type', 'id'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 700 },
        { :name => 'type',  :index => 'type',   :width => 100 },
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true }
      ],
      :pager => '#resources_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'resources_list', grid, options

  end

end
