module PlacesHelper

  include JqgridsHelper

  def places_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/places/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#place_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'place_list', grid, options

  end

end
