module GeneralLedgersHelper

  include JqgridsHelper

  def general_ledgers_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/general_ledgers/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('generalLedger.date'), t('generalLedger.resource'),
                    t('generalLedger.quantity'), t('generalLedger.DC'),
                    t('generalLedger.deal'), t('generalLedger.price'),
                    t('generalLedger.debit'), t('generalLedger.credit')],
      :colModel => [
        { :name => 'date',     :index => 'date',     :width => 80,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'resource', :index => 'resource', :width => 180 },
        { :name => 'quantity', :index => 'quantity', :width => 70 },
        { :name => 'DC',       :index => 'DC',       :width => 70, :search => false, :sortable => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (cellvalue == "debit") return cellvalue;
                           return "credit";
                         }'.to_json_var
        },
        { :name => 'deal', :index => 'deal',         :width => 100, :search => false, :sortable => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.deal) return rowObject.deal;
                           return rowObject[3];
                         }'.to_json_var
        },
        { :name => 'price', :index => 'price',       :width => 100, :search => false, :sortable => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject[2] == 0) return "0";
                           if (rowObject.price) return rowObject.price;
                           return ((rowObject[5] + rowObject[6]) / rowObject[2]).toFixed(2);
                         }'.to_json_var
        },
        { :name => 'debit', :index => 'debit',       :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.debit) return rowObject.debit;
                           return "";
                         }'.to_json_var
        },
        { :name => 'credit', :index => 'credit',     :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.credit) return "";
                           return rowObject[5].toFixed(2);
                         }'.to_json_var
        }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'date',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onPaging => 'function(param)
      {
        fixPager(param, "data_pager");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        var dataIDs = $("#data_list").getDataIDs();
        for(var i = 0; i < dataIDs.length; i++) {
          var rowData = $("#data_list").getRowData(dataIDs[i]);
          function getPrice() {
            if (rowData.quantity == 0) return "0";
            return (rowData.price / rowData.quantity).toFixed(2);
          }
          function getDebit() {
            return (rowData.quantity * rowData.price).toFixed(2);
          }
          $("#data_list").addRowData("sub", { date: "",
                                              resource: "",
                                              quantity: "",
                                              DC: "debit",
                                              deal: rowData.deal,
                                              price: getPrice(),
                                              debit: getDebit(),
                                              credit: "null" }, "after", dataIDs[i]);
        }
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        return false;
      }'.to_json_var
    }]
    
    pager = [:navGrid, '#data_pager', {:refresh => false, :add => false,
                                       :del=> false, :edit => false,
                                       :search => false, :view => false, :cloneToTop => true},
                                      {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#data_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#data_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#data_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#data_list_toppager_left', button_find_data]

    jqgrid_api 'data_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
