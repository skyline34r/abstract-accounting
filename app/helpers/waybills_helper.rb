module WaybillsHelper

  include JqgridsHelper

  def waybills_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :datatype => 'local',
      :colNames => ['resource', 'amount', 'unit'],
      :colModel => [ { :name => 'resource', :index => 'resource', :editable => true,
                       :width => 300 },
                     { :name => 'amount',   :index => 'amount',   :editable => true,
                       :width => 120 },
                     { :name => 'unit',     :index => 'unit',     :editable => true,
                       :width => 80 }],
      :pager => '#waybills_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => 'function(id) {
        if(editSelId >= 0) {
          $("#waybills_list").saveRow(editSelId, false, "clientArray");
          $("#waybills_list").restoreRow(editSelId);
          editSelId = -1;
        }
      }'.to_json_var,
      :ondblClickRow => 'function(id) {
        if(editSelId >= 0) {
          $("#waybills_list").saveRow(editSelId, false, "clientArray");
          $("#waybills_list").restoreRow(editSelId);
        }
        editSelId = id;
        $("#waybills_list").editRow(id,true);
      }'.to_json_var,
      :loadComplete => 'function()
      {
        uin = 0;
        $("#waybills_list").addRowData(uin, { resource: ""
                                            , amount: ""
                                            , unit: "" });
        uin++;
      }'.to_json_var
    }]

    pager = [:navGrid, '#waybills_pager', {:refresh => false, :add => false,
                                           :del=> false, :edit => false,
                                           :search => false, :view => false},
                                          {}, {}, {}]
    
    pager_button_add = [:navButtonAdd, '#waybills_pager', {:caption => 'Add',
      :buttonicon => 'ui-icon-plus', :onClickButton =>
      'function() {
        $("#waybills_list").addRowData(uin, { resource: ""
                                            , amount: ""
                                            , unit: "" });
        uin++;
       }'.to_json_var }]
    pager_button_edit = [:navButtonAdd, '#waybills_pager', {:caption => 'Edit',
      :buttonicon => 'ui-icon-pencil', :onClickButton =>
      'function() {
       }'.to_json_var }]
    pager_button_del = [:navButtonAdd, '#waybills_pager', {:caption => 'Del',
      :buttonicon => 'ui-icon-trash', :onClickButton =>
      'function() {
         $("#waybills_list").delRowData($("#waybills_list").getGridParam("selrow"));
       }'.to_json_var }]

    jqgrid_api 'waybills_list', grid, pager, pager_button_add, pager_button_edit,
                                pager_button_del, options

  end

end
