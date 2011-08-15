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
        { :name => 'place',       :index => 'place',       :width => 150 },
        { :name => 'resource',    :index => 'resource',    :width => 300 },
        { :name => 'real_amount', :index => 'real_amount', :width => 150 },
        { :name => 'amount',      :index => 'amount',      :width => 150 },
        { :name => 'unit',        :index => 'unit',        :width => 55 }
      ],
      :pager => '#storehouse_pager',
      :rowNum => 30,
      :rowList => [30, 50, 100],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :height => "100%",
      :gridview => true,
      :toppager => true,
      :onPaging => 'function(param)
      {
        fixPager(param, "storehouse_list");
      }'.to_json_var
    }]

    pager = [:navGrid, '#storehouse_pager', {:refresh => false, :add => false,
                                             :del=> false, :edit => false,
                                             :search => false, :view => false, :cloneToTop => true},
                                            {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#storehouse_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#storehouse_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#storehouse_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#storehouse_list_toppager_left', button_find_data]

    jqgrid_api 'storehouse_list', grid, options, pager, pager_button_find, pager_button_find1

  end


  def storehouse_release_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/view?release=true',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', t('storehouse.releaseNewList.resource'),
                    t('storehouse.releaseNewList.amount'),
                    t('storehouse.releaseNewList.release'),
                    t('storehouse.releaseNewList.unit')],
      :colModel => [
        { :name => 'check',  :index => 'check', :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(((storeHouseData[options.rowId] == undefined)&&(!rowObject.check)) ||
                              (rowObject.check == "uncheck")) {
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
                           if(rowObject.resource != undefined) {
                             return rowObject.resource;
                           }
                           return rowObject[1];
                         }'.to_json_var },
        { :name => 'amount',  :index => 'amount',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.amount != undefined) {
                             return rowObject.amount;
                           }
                           return rowObject[2];
                         }'.to_json_var },
        { :name => 'release', :index => 'release', :width => 200, :search => false,
          :editable => true, :sortable => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(cellvalue == " ") cellvalue = "";
                           if(cellvalue == rowObject[3]) {
                             if(storeHouseData[options.rowId] == undefined) {
                               return "";
                             }
                             return storeHouseData[options.rowId].release;
                           }
                           if(isNaN(cellvalue) || (cellvalue == "") ||
                               (parseInt(cellvalue) <= "0")) {
                             $("#check_" + options.rowId).removeAttr("checked");
                             delete storeHouseData[options.rowId];
                             return "";
                           }
                           if(storeHouseData[options.rowId] == undefined) {
                             storeHouseData[options.rowId] = new Object();
                             storeHouseData[options.rowId].resource =
                               $("#storehouse_release_list").getCell(options.rowId, "resource");
                             storeHouseData[options.rowId].amount =
                               $("#storehouse_release_list").getCell(options.rowId, "amount");
                             storeHouseData[options.rowId].unit =
                               $("#storehouse_release_list").getCell(options.rowId, "unit");
                           }
                           storeHouseData[options.rowId].release = cellvalue;
                           return cellvalue;
                         }'.to_json_var },
        { :name => 'unit',  :index => 'unit',   :width => 50,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.unit != undefined) {
                             return rowObject.unit;
                           }
                           return rowObject[3];
                         }'.to_json_var },

      ],
      :pager => '#storehouse_release_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'product.resource.tag',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :editurl => 'clientArray',
      :cellsubmit => 'clientArray',
      :gridview => true,
      :toppager => true,
      :beforeRequest => 'function()
      {
        if(location.hash.substr(0,19) == "#storehouses/return") {
          $("#storehouse_release_list").setGridParam({url: "/storehouses/return/return_list"});
        }
        if(dataPage != null) {
          storeHouseData = dataPage["dataGrid"];
          $("#storehouse_to").val(dataPage["to"]);
          $("#storehouse_date").val(dataPage["date"]);
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
      :onPaging => 'function(param)
      {
        fixPager(param, "storehouse_release_list");
        $("#storehouse_release_list").saveRow(lastSelId);
      }'.to_json_var,
      :loadComplete => 'function()
      {
        storeHouseDataIDs = $("#storehouse_release_list").getDataIDs();
        for (var i in storeHouseData) {
          if(jQuery.inArray(i, $("#storehouse_release_list").getDataIDs()) >= 0) {
            $("#storehouse_release_list").delRowData(i);
          }
          $("#storehouse_release_list").addRowData(i,
                                                   { check: "check"
                                                   , resource: storeHouseData[i].resource
                                                   , amount: storeHouseData[i].amount
                                                   , release: storeHouseData[i].release
                                                   , unit: storeHouseData[i].unit }
                                                   , "first");
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#storehouse_release_pager', {:refresh => false, :add => false,
                                                     :del=> false, :edit => false,
                                                     :search => false, :view => false, :cloneToTop => true},
                                                    {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#storehouse_release_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#storehouse_release_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#storehouse_release_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#storehouse_release_list_toppager_left', button_find_data]

    jqgrid_api 'storehouse_release_list', grid, options, pager, pager_button_find, pager_button_find1

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
        { :name => 'created',   :index => 'created',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var },
        { :name => 'owner', :index => 'owner', :width => 200 },
        { :name => 'to',    :index => 'to',    :width => 200 },
        { :name => 'place', :index => 'place', :width => 200 },
        { :name => 'state', :index => 'state', :width => 100, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return getReleaseStatus(cellvalue);
                         }'.to_json_var },
      ],
      :rowNum => 30,
      :rowList => [30, 50, 100],
      :height => "100%",
      :pager => '#releases_pager',
      :sortname => 'created',
      :sortorder => 'asc',
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :subGrid => true,
      :subGridUrl => '/storehouses/view_release',
      :subGridModel => [
        { :name => [ t('storehouse.entryList.resource'),
                     t('storehouse.entryList.amount'),
                     t('storehouse.entryList.unit') ],
          :width => [300, 100, 100],
          :params => [
            { :name => 'resource', :index => 'resource' },
            { :name => 'amount',   :index => 'amount' },
            { :name => 'unit', :index => 'unit' }
          ]
        }
      ],
      :subGridBeforeExpand => 'function(pId, id)
      {
        $("#releases_list").setGridParam({subGridUrl: "/storehouses/view_release?id=" + id });
      }'.to_json_var,
      :onSelectRow => 'function(cell)
      {
        $("#view_release").removeAttr("disabled");
        $("#view_release_1").removeAttr("disabled");
      }'.to_json_var,
      :beforeRequest => 'function()
      {
        var link = "/storehouses/releases/list";
        var state = location.hash.substr(28, location.hash.length);
        if(state.length != 0) {
            link += "?state=" + state;
        }
        $("#releases_list").setGridParam({url: link});
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "releases_list");
      }'.to_json_var
    }]

    pager = [:navGrid, '#releases_pager', {:refresh => false, :add => false,
                                             :del=> false, :edit => false,
                                             :search => false, :view => false, :cloneToTop => true},
                                            {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#releases_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#releases_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#releases_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#releases_list_toppager_left', button_find_data]

    jqgrid_api 'releases_list', grid, options, pager, pager_button_find, pager_button_find1

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
        { :name => 'resource', :index => 'product.resource.tag', :width => 450 },
        { :name => 'amount',   :index => 'amount',   :width => 295 },
        { :name => 'unit',     :index => 'product.unit',     :width => 55 }
      ],
      :pager => '#release_view_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'product.resource.tag',
      :sortorder => 'asc',
      :viewrecords => true,
      :beforeRequest => 'function()
      {
        $("#release_view_list").setGridParam({url: "/storehouses/view_release?id="
                                                    + location.hash.substr(30)});
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "release_view_list");
      }'.to_json_var
    }]

    jqgrid_api 'release_view_list', grid, options

  end


  def release_waybills_jqgrid_tree

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/waybill_list',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', t('waybill.tree.document_id'), t('waybill.tree.date'),
                    t('waybill.tree.organization'), t('waybill.tree.owner'),
                    t('waybill.tree.vatin'), t('waybill.tree.place'), "in_storehouse"],
      :colModel => [
        { :name => 'check',  :index => 'check', :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           var in_warehouse = true;
                           if (rowObject.in_storehouse != undefined) in_warehouse = rowObject.in_storehouse;
                           else in_warehouse = rowObject[6];
                           if (!in_warehouse) {
                             return "";
                           }
                           if(((storeHouseData[options.rowId] == undefined)&&(!rowObject.check)) ||
                              (rowObject.check == "uncheck")) {
                             return "<input type=\'checkbox\' id=\'check_waybill_"
                               + options.rowId + "\' onClick=\'check_waybill(\""
                               + options.rowId + "\"); \'>";
                           }
                           return "<input type=\'checkbox\' id=\'check_waybill_"
                             + options.rowId + "\' onClick=\'check_waybill(\""
                             + options.rowId + "\"); \' checked>";
                         }'.to_json_var },
        { :name => 'document_id', :index => 'document_id', :width => 110,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.document_id != undefined) {
                             return rowObject.document_id;
                           }
                           return rowObject[0];
                         }'.to_json_var },
        { :name => 'created', :index => 'created', :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.created != undefined) {
                             return rowObject.created;
                           }
                           return rowObject[1].substr(0,10);
                         }'.to_json_var },
        { :name => 'from', :index => 'from', :width => 180,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.from != undefined) {
                             return rowObject.from;
                           }
                           return rowObject[2];
                         }'.to_json_var },
        { :name => 'owner', :index => 'owner', :width => 180,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.owner != undefined) {
                             return rowObject.owner;
                           }
                           return rowObject[3];
                         }'.to_json_var },
        { :name => 'place', :index => 'place', :width => 146,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.place != undefined) {
                             return rowObject.place;
                           }
                           return rowObject[4];
                         }'.to_json_var },
        { :name => 'vatin', :index => 'vatin', :width => 90,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.vatin != undefined) {
                             return rowObject.vatin;
                           }
                           return rowObject[5];
                         }'.to_json_var },
        { :name => 'in_storehouse', :index => 'in_storehouse', :hidden => true,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.in_storehouse != undefined) {
                             return rowObject.in_storehouse;
                           }
                           return rowObject[6];
                         }'.to_json_var }
      ],
      :pager => '#release_waybills_tree_pager',
      :height => "100%",
      :rowNum => 30,
      :rowList => [30, 50, 100],
      :sortname => 'created',
      :sortorder => 'asc',
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :beforeSelectRow =>	'function()
      {
        if(canSave) {
          $("#" + lastSubgridTableId).saveRow(lastSelId);
        }
        return false;
      }'.to_json_var,
      :loadComplete => 'function()
      {
        storeHouseDataIDs = $("#release_waybills_tree").getDataIDs();
        var grid = $("#release_waybills_tree");
        var subGridCells = $("td.sgcollapsed",grid[0]);
        $.each(subGridCells,function(i,value){
            if ($("#release_waybills_tree").getCell(storeHouseDataIDs[i], "in_storehouse") == "false") {
                $(value).unbind("click").html("");
            }
        });
        if(listAction != "") {
          var _id = listAction;
          listAction = "check_waybill";
          $("#check_waybill_" + _id).attr("checked", "checked");
          $("#release_waybills_tree").expandSubGridRow(_id);
        } else {
          for (var i in storeHouseData) {
            if(jQuery.inArray(i, $("#release_waybills_tree").getDataIDs()) >= 0) {
              $("#release_waybills_tree").delRowData(i);
            }
            $("#release_waybills_tree").addRowData(i, { check: "check"
                                                      , document_id: storeHouseData[i].document_id
                                                      , created: storeHouseData[i].created
                                                      , from: storeHouseData[i].from
                                                      , owner: storeHouseData[i].owner
                                                      , place: storeHouseData[i].place
                                                      , vatin: storeHouseData[i].vatin
                                                      , in_storehouse: storeHouseData[i].in_storehouse }
                                                      , "first");
          }
        }
      }'.to_json_var,
      :subGrid => true,
      :subGridRowExpanded => 'function(subgrid_id, row_id)
      {
        var subgrid_table_id = subgrid_id + "_t";
        $("#"+subgrid_id).html("<table id=\"" + subgrid_table_id + "\" onmouseup=\"canSave = false;\"></table>");
        var url, datatype, mtype, modelResource, modelAmount, modelUnit;
        if(localExpand) {
          url = null;
          datatype = "local";
          mtype = null;
          modelResource = { name: "resource", index: "resource", width: 300, sortable: false };
          modelAmount = { name: "amount", index: "amount", width: 93, sortable: false, resizable: false };
          modelUnit = { name: "unit", index: "unit", width: 93, sortable: false, resizable: false };
          localExpand = false;
        } else {
          url = "/storehouses/" + row_id + "/waybill_entries_list";
          datatype = "json";
          mtype = "GET";
          modelResource = { name: "resource", index: "resource", width: 300, sortable: false,
                            resizable: false, formatter: function (cellvalue, options, rowObject) {
                              return rowObject[0];
                            }};
          modelAmount = { name: "amount", index: "amount", width: 93, sortable: false,
                          resizable: false, formatter: function (cellvalue, options, rowObject) {
                            return rowObject[1];
                          }};
          modelUnit = { name: "unit", index: "unit", width: 93, sortable: false,
                        resizable: false, formatter: function (cellvalue, options, rowObject) {
                          return rowObject[2];
                        }};
        }
        $("#"+subgrid_table_id).jqGrid({
          url: url,
          datatype: datatype,
          mtype: mtype,
          colNames: ["", getReleaseEntryColumn("resource"), getReleaseEntryColumn("amount"),
                     getReleaseEntryColumn("release"), getReleaseEntryColumn("unit")],
          colModel: [{ name: "check", index: "check", width: 14, sortable: false, resizable: false,
                        formatter: function (cellvalue, options, rowObject) {// alert(storeHouseData.toSource());
                          if((listAction == "check_waybill") || ((storeHouseData[row_id] != null) &&
                             (storeHouseData[row_id].data != null) &&
                             (storeHouseData[row_id].data[options.rowId] != null))) {
                            return "<input type=\'checkbox\' id=\'check_entry_" + row_id + "_"
                                       + options.rowId + "\' onClick=\'check_release_waybill(\""
                                       + row_id + "\", \"" + options.rowId + "\"); \' checked>";
                          }
                          return "<input type=\'checkbox\' id=\'check_entry_" + row_id + "_"
                                     + options.rowId + "\' onClick=\'check_release_waybill(\""
                                       + row_id + "\", \"" + options.rowId + "\"); \'>";
                        }},
                     modelResource,
                     modelAmount,
                     { name: "release", index: "release", width: 93, sortable: false, editable: true,
                       resizable: false, formatter: function (cellvalue, options, rowObject) {
                         if(listAction == "check_waybill") {
                           cellvalue = rowObject[1];
                         }
                         if(isNaN(cellvalue)) {
                           if((storeHouseData[row_id] == null) || (storeHouseData[row_id].data == null) ||
                              (storeHouseData[row_id].data[options.rowId] == null)) {
                             return "";
                           }
                           return storeHouseData[row_id].data[options.rowId];
                         }
                         if((cellvalue == "") || (parseInt(cellvalue) <= "0") || (cellvalue == " ")) {
                           if(cellvalue == " ") cellvalue = "";
                           $("#check_entry_" + row_id + "_" + options.rowId).removeAttr("checked");
                           uncheckParentWaybill(row_id);
                           if((storeHouseData[row_id] != null) && (storeHouseData[row_id].data != null)){
                             delete storeHouseData[row_id].data[options.rowId];
                             if(storeHouseData[row_id].data.toSource().length == 4) {
                               delete storeHouseData[row_id];
                             }
                           }
                           return "";
                         }
                         if(storeHouseData[row_id] == null) {
                           storeHouseData[row_id] = new Object();
                           storeHouseData[row_id].data = new Object();
                           storeHouseData[row_id].document_id =
                             $("#release_waybills_tree").getCell(row_id, "document_id");
                           storeHouseData[row_id].created =
                             $("#release_waybills_tree").getCell(row_id, "created");
                           storeHouseData[row_id].from =
                             $("#release_waybills_tree").getCell(row_id, "from");
                           storeHouseData[row_id].owner =
                             $("#release_waybills_tree").getCell(row_id, "owner");
                           storeHouseData[row_id].place =
                             $("#release_waybills_tree").getCell(row_id, "place");
                           storeHouseData[row_id].vatin =
                             $("#release_waybills_tree").getCell(row_id, "vatin");
                           storeHouseData[row_id].in_storehouse =
                             $("#release_waybills_tree").getCell(row_id, "in_storehouse");
                         }
                         storeHouseData[row_id].data[options.rowId] = cellvalue;
                         return cellvalue;
                     }},
                     modelUnit
                    ],
          height: "100%",
          editurl: "clientArray",
          cellsubmit: "clientArray",
          loadComplete: function () {
            listAction = "";
          },
          onSelectRow: function(id)
          {
            if(lastSelId != "") {
              $("#" + subgrid_table_id).saveRow(lastSelId);
            }
            lastSelId = id;
            lastSubgridTableId = subgrid_table_id;
            if($("#check_entry_" + row_id + "_" + id).is(":checked")) {
              $("#" + subgrid_table_id).editRow(id, true);
            }
          }
        });
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "release_waybills_tree");
      }'.to_json_var
    }]

    pager = [:navGrid, '#release_waybills_tree_pager', {:refresh => false, :add => false,
                                                        :del=> false, :edit => false,
                                                        :search => false, :view => false, :cloneToTop => true},
                                                       {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#release_waybills_tree")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#release_waybills_tree")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#release_waybills_tree_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#release_waybills_tree_toppager_left', button_find_data]

    jqgrid_api 'release_waybills_tree', grid, options, pager, pager_button_find, pager_button_find1

  end

  def storehouse_return_list_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/return/return_list',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('storehouse.storehouseList.resource'),
                    t('storehouse.storehouseList.real_amount'),
                    t('storehouse.storehouseList.unit')],
      :colModel => [
        { :name => 'resource', :index => 'resource', :width => 500,
          :formatter => 'function (cellvalue, options, rowObject) {
                           return rowObject[1];
                         }'.to_json_var },
        { :name => 'amount',   :index => 'amount',   :width => 200,
          :formatter => 'function (cellvalue, options, rowObject) {
                           return rowObject[2];
                         }'.to_json_var },
        { :name => 'unit',     :index => 'unit',     :width => 100,
          :formatter => 'function (cellvalue, options, rowObject) {
                           return rowObject[3];
                         }'.to_json_var }
      ],
      :pager => '#storehouse_return_pager',
      :rowNum => 30,
      :rowList => [30, 50, 100],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :height => "100%",
      :gridview => true,
      :toppager => true,
      :onPaging => 'function(param)
      {
        fixPager(param, "storehouse_return_list");
      }'.to_json_var
    }]

    pager = [:navGrid, '#storehouse_return_pager', {:refresh => false, :add => false,
                                                    :del=> false, :edit => false,
                                                    :search => false, :view => false, :cloneToTop => true},
                                                   {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#storehouse_return_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#storehouse_return_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#storehouse_return_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#storehouse_return_list_toppager_left', button_find_data]

    jqgrid_api 'storehouse_return_list', grid, options, pager, pager_button_find, pager_button_find1

  end

  def storehouse_return_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/storehouses/return/return_list',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', t('storehouse.releaseNewList.resource'),
                    t('storehouse.releaseList.place'),
                    t('storehouse.releaseList.owner'),
                    t('storehouse.releaseNewList.amount'),
                    'owner_id',
                    t('storehouse.releaseNewList.release'),
                    t('storehouse.releaseNewList.unit'),
                    'resource_id'],
      :colModel => [
        { :name => 'check',  :index => 'check', :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if((((storeHouseData[options.rowId.split("_")[0]] == undefined) ||
                                (storeHouseData[options.rowId.split("_")[0]][1] != rowObject[5])) &&
                               (!rowObject.check)) || (rowObject.check == "uncheck")) {
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
                           if(rowObject.resource != undefined) {
                             return rowObject.resource;
                           }
                           return rowObject[1];
                         }'.to_json_var },
        { :name => 'place',  :index => 'place',   :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.place != undefined) {
                             return rowObject.place;
                           }
                           return rowObject[0];
                         }'.to_json_var },
        { :name => 'entity',  :index => 'entity',   :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.entity != undefined) {
                             return rowObject.entity;
                           }
                           return rowObject[4];
                         }'.to_json_var },
        { :name => 'amount',  :index => 'amount',   :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.amount != undefined) {
                             return rowObject.amount;
                           }
                           return rowObject[2];
                         }'.to_json_var },
        { :name => 'owner_id', :index => 'owner_id', :width => 50, :hidden => true},
        { :name => 'release', :index => 'release', :width => 100, :search => false,
          :editable => true, :sortable => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(cellvalue == " ") cellvalue = "";
                           if(cellvalue == rowObject[6]) {
                             if((storeHouseData[options.rowId.split("_")[0]] == undefined) ||
                                (storeHouseData[options.rowId.split("_")[0]][1] != rowObject[5])) {
                               return "";
                             }
                             return storeHouseData[options.rowId.split("_")[0]].release[0];
                           }
                           if(isNaN(cellvalue) || (cellvalue == "") ||
                               (parseInt(cellvalue) <= "0")) {
                             $("#check_" + options.rowId).removeAttr("checked");
                             delete storeHouseData[options.rowId.split("_")[0]];
                             return "";
                           }
                           if(storeHouseData[options.rowId.split("_")[0]] == undefined) {
                             storeHouseData[options.rowId.split("_")[0]] = new Object();
                             storeHouseData[options.rowId.split("_")[0]].resource =
                               $("#storehouse_return_list").getCell(options.rowId, "resource");
                             storeHouseData[options.rowId.split("_")[0]].place =
                               $("#storehouse_return_list").getCell(options.rowId, "place");
                             storeHouseData[options.rowId.split("_")[0]].entity =
                               $("#storehouse_return_list").getCell(options.rowId, "entity");
                             storeHouseData[options.rowId.split("_")[0]].amount =
                               $("#storehouse_return_list").getCell(options.rowId, "amount");
                             storeHouseData[options.rowId.split("_")[0]].owner_id =
                               $("#storehouse_return_list").getCell(options.rowId, "owner_id");
                             storeHouseData[options.rowId.split("_")[0]].unit =
                               $("#storehouse_return_list").getCell(options.rowId, "unit");
                             storeHouseData[options.rowId.split("_")[0]].resource_id =
                               $("#storehouse_return_list").getCell(options.rowId, "resource_id");
                           }
                           if($("#storehouse_return_list").getCell(options.rowId, "owner_id")) {
                             storeHouseData[options.rowId.split("_")[0]].release =
                               [cellvalue, $("#storehouse_return_list").getCell(options.rowId, "owner_id")];
                           }
                           return cellvalue;
                         }'.to_json_var },
        { :name => 'unit',  :index => 'unit',   :width => 55,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject.unit != undefined) {
                             return rowObject.unit;
                           }
                           return rowObject[3];
                         }'.to_json_var },
        { :name => 'resource_id', :index => 'resource_id', :width => 5, :hidden => true }
      ],
      :pager => '#storehouse_return_pager',
      :rowNum => 4,
      :rowList => [4, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :editurl => 'clientArray',
      :cellsubmit => 'clientArray',
      :gridview => true,
      :toppager => true,
      :beforeRequest => 'function()
      {
        if(dataPage != null) {
          storeHouseData = dataPage["dataGrid"];
          $("#storehouse_to").val(dataPage["to"]);
          $("#storehouse_date").val(dataPage["date"]);
        }
      }'.to_json_var,
      :onSelectRow => 'function(id)
      {
        if(lastSelId != "") {
          $("#storehouse_return_list").saveRow(lastSelId);
        }
        lastSelId = id;
        if($("#check_" + id).is(":checked")) {
          $("#storehouse_return_list").editRow(id, true);
        }
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "storehouse_return_list");
        $("#storehouse_return_list").saveRow(lastSelId);
      }'.to_json_var,
      :loadComplete => 'function()
      {
        storeHouseDataIDs = $("#storehouse_return_list").getDataIDs();
        for (var i in storeHouseData) {
          for (var j=0; j<storeHouseDataIDs.length; j++) {
            if(i == storeHouseDataIDs[j].split("_")[0]) $("#storehouse_return_list").delRowData(storeHouseDataIDs[j]);
          }
          $("#storehouse_return_list").addRowData(i.toString() + "_" + storeHouseData[i].release[1]
                                                 , { check: "check"
                                                   , resource: storeHouseData[i].resource
                                                   , place: storeHouseData[i].place
                                                   , entity: storeHouseData[i].entity
                                                   , amount: storeHouseData[i].amount
                                                   , owner_id: storeHouseData[i].owner_id
                                                   , release: storeHouseData[i].release[0]
                                                   , unit: storeHouseData[i].unit
                                                   , resource_id: storeHouseData[i].resource_id }
                                                   , "first");
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#storehouse_return_pager', {:refresh => false, :add => false,
                                                    :del=> false, :edit => false,
                                                    :search => false, :view => false, :cloneToTop => true},
                                                   {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#storehouse_return_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#storehouse_return_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#storehouse_return_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#storehouse_return_list_toppager_left', button_find_data]

    jqgrid_api 'storehouse_return_list', grid, options, pager, pager_button_find, pager_button_find1

  end


end
