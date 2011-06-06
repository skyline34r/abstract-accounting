module BalancesHelper

  include JqgridsHelper

  def balances_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/balances/load?date=',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('balance.deal'), t('balance.entity'),
                    t('balance.resource'), t('balance.debit'),
                    t('balance.credit'), t('balance.side')],
      :colModel => [
        { :name => 'deal',     :index => 'deal',    :width => 240 },
        { :name => 'entity',   :index => 'entity',  :width => 230 },
        { :name => 'resource', :index => 'resource',:width => 230 },
        { :name => 'debit',    :index => 'amount',  :width => 50, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[5] == "active") return "";
                           return cellvalue;
                         }'.to_json_var  },
        { :name => 'credit',   :index => 'value',   :width => 50, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[5] == "passive") return "";
                           if($("#physical").is(":checked"))
                           {
                             return rowObject[3];
                           }
                           return cellvalue;
                         }'.to_json_var    },
        { :name => 'side', :index => 'side', :width => 50, :hidden => true }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'deal',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :loadComplete => 'function()
      {
        ajaxRequest("/balances/total");
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
