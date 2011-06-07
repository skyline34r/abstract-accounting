module QuotesHelper

  include JqgridsHelper

  def quotes_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/quotes/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('quote.resource'), t('quote.date'), t('quote.rate')],
      :colModel => [
        { :name => 'resource', :index => 'resource', :width => 400 },
        { :name => 'day',      :index => 'day',              :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'rate',      :index => 'rate',      :width => 200 }
      ],
      :pager => '#quotes_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onSelectRow => 'function(cell)
      {
        $("#quote_res_btn").val($("#quotes_list").getCell(cell, "resource"));
        $("#quote_datepicker").val($("#quotes_list").getCell(cell, "day"));
        $("#quote_rate").val($("#quotes_list").getCell(cell, "rate"));
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectQuote) return true;
        return false;
      }'.to_json_var
    }]
    
    pager = [:navGrid, '#quotes_pager', {:refresh => false, :add => false,
                                         :del=> false, :edit => false,
                                         :search => false, :view => false, :cloneToTop => true},
                                        {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#quotes_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#quotes_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#quotes_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#quotes_list_toppager_left', button_find_data]

    jqgrid_api 'quotes_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
