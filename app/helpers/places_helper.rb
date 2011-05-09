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
      :viewrecords => true,
      :onSelectRow => 'function(cell)
      {
        $("#place_tag").val($("#place_list").getCell(cell, "tag"));
        $("#change_place").removeAttr("disabled");
        $("#change_place").parent().parent().attr("action",
            "/places/" + cell + "/edit");
      }'.to_json_var
    }]

    jqgrid_api 'place_list', grid, options

  end

end
