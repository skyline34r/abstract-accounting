module StorehousesHelper

  include JqgridsHelper

  def storehouse_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view?entity_id=',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['resource', 'amount'],
      :colModel => [
        { :name => 'resource',  :index => 'resource',   :width => 400 },
        { :name => 'amount',  :index => 'amount',   :width => 400 }
      ],
      :pager => '#storehouse_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :beforeRequest => 'function()
      {
        $("#storehouse_list").setGridParam({url: "/storehouses/view?entity_id="
                                                   + getOwnerId()});
      }'.to_json_var
    }]

    jqgrid_api 'storehouse_list', grid, options

  end


  def storehouse_release_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view?entity_id=',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', 'resource', 'amount', 'release'],
      :colModel => [
        { :name => '',  :index => 'check', :width => 14,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return "<input type=\'checkbox\' id=\'check_"
                             + options.rowId + "\' onClick=\'check_storehouse_waybill(\""
                             + options.rowId + "\"); \'>";
                         }'.to_json_var },
        { :name => 'resource',  :index => 'resource',   :width => 380,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[0];
                         }'.to_json_var },
        { :name => 'amount',  :index => 'amount',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[1];
                         }'.to_json_var },
        { :name => 'release',  :index => 'release',   :width => 200, :editable => true }
      ],
      :pager => '#storehouse_release_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :editurl => 'clientArray',
      :cellsubmit => 'clientArray',
      :beforeRequest => 'function()
      {
        $("#storehouse_release_list").setGridParam({url: "/storehouses/view?entity_id="
                                                          + getOwnerId()});
      }'.to_json_var,
      :onSelectRow => 'function(id)
      {
        if(lastSelId != "") {
          $("#storehouse_release_list").saveRow(lastSelId);
        }
        lastSelId = id;
        if($("#check_" + id).is(":checked")) {
          $("#storehouse_release_list").editRow(id, true);
        }
      }'.to_json_var
    }]

    jqgrid_api 'storehouse_release_list', grid, options

  end

end
