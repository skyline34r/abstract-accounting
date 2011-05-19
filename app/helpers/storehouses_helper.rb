module StorehousesHelper

  include JqgridsHelper

  def storehouse_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('storehouse.storehouseList.place'),
                    t('storehouse.storehouseList.resource'),
                    t('storehouse.storehouseList.real_amount'),
                    t('storehouse.storehouseList.amount'),
                    t('storehouse.storehouseList.unit')],
      :colModel => [
        { :name => 'place',    :index => 'place',    :width => 150 },
        { :name => 'resource', :index => 'resource', :width => 300 },
        { :name => 'real_amount',   :index => 'real_amount',   :width => 150 },
        { :name => 'amount',   :index => 'amount',   :width => 150 },
        { :name => 'unit',     :index => 'unit',     :width => 55 }
      ],
      :pager => '#storehouse_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'storehouse_list', grid, options

  end


  def storehouse_release_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', t('storehouse.releaseNewList.resource'),
                    t('storehouse.releaseNewList.amount'),
                    t('storehouse.releaseNewList.release'),
                    t('storehouse.releaseNewList.unit')],
      :colModel => [
        { :name => '',  :index => 'check', :width => 14,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(storeHouseData[options.rowId] == undefined) {
                             return "<input type=\'checkbox\' id=\'check_"
                               + options.rowId + "\' onClick=\'check_storehouse_waybill(\""
                               + options.rowId + "\"); \'>";
                           }
                           return "<input type=\'checkbox\' id=\'check_"
                             + options.rowId + "\' onClick=\'check_storehouse_waybill(\""
                             + options.rowId + "\"); \' checked>";
                         }'.to_json_var },
        { :name => 'resource',  :index => 'resource',   :width => 330,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[1];
                         }'.to_json_var },
        { :name => 'amount',  :index => 'amount',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[2];
                         }'.to_json_var },
        { :name => 'release',  :index => 'release',   :width => 200, :editable => true,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(cellvalue == " ") cellvalue = "";
                           if(cellvalue == rowObject[3]) {
                             if(storeHouseData[options.rowId] == undefined) {
                               return "";
                             }
                             return storeHouseData[options.rowId];
                           }
                           if(isNaN(cellvalue) || (cellvalue == "") ||
                               (parseInt(cellvalue) <= "0")) {
                             $("#check_" + options.rowId).removeAttr("checked");
                             delete storeHouseData[options.rowId];
                             return "";
                           }
                           storeHouseData[options.rowId] = cellvalue;
                           return cellvalue;
                         }'.to_json_var },
        { :name => 'unit',  :index => 'unit',   :width => 50,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[3];
                         }'.to_json_var },

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
        if(dataPage != null) {
          storeHouseData = dataPage["dataGrid"];
          $("#storehouse_to").val(dataPage["to"]);
          $("#storehouse_date").val(dataPage["date"]);
          dataPage = null;
        }
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
      }'.to_json_var,
      :onPaging => 'function()
      {
        $("#storehouse_release_list").saveRow(lastSelId);
      }'.to_json_var
    }]

    jqgrid_api 'storehouse_release_list', grid, options

  end


  def releases_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/releases/list',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('storehouse.releaseList.date'),
                    t('storehouse.releaseList.owner'),
                    t('storehouse.releaseList.to'),
                    t('storehouse.releaseList.place'),
                    t('storehouse.releaseList.status')],
      :colModel => [
        { :name => 'date',   :index => 'date',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var },
        { :name => 'owner',  :index => 'owner',  :width => 200 },
        { :name => 'to',     :index => 'to',     :width => 200 },
        { :name => 'place',  :index => 'place',  :width => 200 },
        { :name => 'status', :index => 'status', :width => 100, :hidden => true,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return getReleaseStatus(cellvalue);
                         }'.to_json_var },
      ],
      :pager => '#releases_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'date',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => 'function(cell)
      {
        $("#view_release").removeAttr("disabled");
      }'.to_json_var        
    }]

    jqgrid_api 'releases_list', grid, options

  end


  def release_view_entries_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view_release?id=',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [ t('storehouse.entryList.resource'),
                     t('storehouse.entryList.amount'),
                     t('storehouse.entryList.unit') ],
      :colModel => [
        { :name => 'resource', :index => 'resource', :width => 450 },
        { :name => 'amount',   :index => 'amount',   :width => 295 },
        { :name => 'unit',     :index => 'unit',     :width => 55 }
      ],
      :pager => '#release_view_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :beforeRequest => 'function()
      {
        $("#release_view_list").setGridParam({url: "/storehouses/view_release?id="
                                                    + location.hash.substr(30)});
      }'.to_json_var
    }]

    jqgrid_api 'release_view_list', grid, options

  end

end
