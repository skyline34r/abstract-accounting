module BalancesHelper

  include JqgridsHelper

  def balances_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/balances',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['deal', 'entity', 'resource', 'debit', 'credit', 'side'],
      :colModel => [
        { :name => 'deal',     :index => 'deal.tag',        :width => 240 },
        { :name => 'entity',   :index => 'deal.entity.tag', :width => 230 },
        { :name => 'resource', :index => 'deal.give.tag',   :width => 230 },
        { :name => 'debit',    :index => 'amount',          :width => 50,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[5] == "active") return "";
                           return cellvalue;
                         }'.to_json_var  },
        { :name => 'credit',   :index => 'value',           :width => 50,
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
      :pager => '#balances_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'flow',
      :sortorder => 'asc',
      :viewrecords => true
    }]
    
    jqgrid_api 'balances_list', grid, options

  end

end
