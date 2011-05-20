module WaybillsHelper

  include JqgridsHelper

  def waybills_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :datatype => 'local',
      :colNames => [t('waybill.entryList.resource') + '*',
                    t('waybill.entryList.amount') + '*',
                    t('waybill.entryList.unit') + '*'],
      :colModel => [ { :name => 'resource', :index => 'resource', :editable => true,
                       :width => 300 },
                     { :name => 'amount',   :index => 'amount',   :editable => true,
                       :width => 120, :formatter => 'function(cellvalue, options, rowObject) {
                           if(isNaN(cellvalue) || (cellvalue == "") ||
                               (parseInt(cellvalue) <= "0")) {
                             return "";
                           }
                           return cellvalue;
                         }'.to_json_var },
                     { :name => 'unit',     :index => 'unit',     :editable => true,
                       :width => 80 }],
      :pager => '#waybills_pager',
      :rowNum => 10,
      :cellEdit => true,
      :editurl => 'clientArray',
      :cellsubmit => 'clientArray',
      :rowList => [10, 20, 30],
      :rownumbers => true,
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true,
      :beforeEditCell => 'function(rowid, cellname, value, iRow, iCol)
      {
        editRowId = iRow;
        editColId = iCol;
      }'.to_json_var
    }]

    pager = [:navGrid, '#waybills_pager', {:refresh => false, :add => false,
                                           :del=> false, :edit => false,
                                           :search => false, :view => false},
                                          {}, {}, {}]
    
    pager_button_add = [:navButtonAdd, '#waybills_pager', {
      :caption => t('waybill.entryList.btn_add'), :buttonicon => 'ui-icon-plus',
      :onClickButton => 'function() {
        $("#waybills_list").addRowData(uin, { resource: ""
                                            , amount: ""
                                            , unit: "" });
        uin++;
      }'.to_json_var }]
    pager_button_del = [:navButtonAdd, '#waybills_pager', {
      :caption => t('waybill.entryList.btn_del'), :buttonicon => 'ui-icon-trash',
      :onClickButton => 'function() {
        if($("#waybills_list").getGridParam("selrow") != null) {
          $("#waybills_list").delRowData($("#waybills_list").getGridParam("selrow"));
          var data = $("#waybills_list").getRowData();
          $("#waybills_list").clearGridData();
          for(uin=0; uin<data.length; uin++) {
            $("#waybills_list").addRowData(uin, data[uin]);
          }
        }
      }'.to_json_var }]

    jqgrid_api 'waybills_list', grid, pager, pager_button_add, pager_button_del,
                                options

  end


  def waybills_jqgrid_tree

    options = {:on_document_ready => true}

    grid = [{
      :url => '/waybills/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('waybill.tree.document_id'), t('waybill.tree.date'),
                    t('waybill.tree.organization'), t('waybill.tree.owner'),
                    t('waybill.tree.vatin'), t('waybill.tree.place')],
      :colModel => [
        { :name => 'document_id', :index => 'document_id', :width => 110 },
        { :name => 'date', :index => 'date', :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var },
        { :name => 'organization',  :index => 'organization',   :width => 185 },
        { :name => 'owner',         :index => 'owner',          :width => 185 },
        { :name => 'place',         :index => 'place',          :width => 150 },
        { :name => 'vatin',         :index => 'vatin',          :width => 90 }
      ],
      :pager => '#waybills_tree_pager',
      :height => "450px",
      :rowNum => 30,
      :rowList => [30, 50, 100],
      :sortname => 'id',
      :sortorder => 'asc',
      :viewrecords => true,
      :subGrid => true,
      :subGridUrl => '/waybills/',
      :subGridModel => [
        { :name => [t('waybill.tree.resource'), t('waybill.tree.amount'),
                    t('waybill.tree.unit')],
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
        $("#waybills_tree").setGridParam({subGridUrl: "/waybills/" + id });
      }'.to_json_var
    }]

    jqgrid_api 'waybills_tree', grid, options

  end

end
