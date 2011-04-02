module EntitiesHelper

  include JqgridsHelper

  def entities_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#entity_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => 'function(cell)
      {
        $("#entity_tag").val($("#entity_list").getCell(cell, "tag"));
        $("#change_entity").removeAttr("disabled");
        $("#change_entity").parent().parent().attr("action",
            "/entities/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectEntity) return true;
        return false;
      }'.to_json_var
    }]

    jqgrid_api 'entity_list', grid, options

  end

end
