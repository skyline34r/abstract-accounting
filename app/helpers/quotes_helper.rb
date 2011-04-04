module QuotesHelper

  include JqgridsHelper

  def quotes_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/quotes/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['resource', 'day', 'rate'],
      :colModel => [
        { :name => 'resource', :index => 'money.alpha_code', :width => 400 },
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
      :viewrecords => true,
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
    
    jqgrid_api 'quotes_list', grid, options

  end

end
