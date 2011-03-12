module BalancesHelper

  include JqgridsHelper

  def balances_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/balances',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['deal', 'entity', 'resource', 'debit', 'credit'],
      :colModel => [
        { :name => 'deal',     :index => 'deal.tag',        :width => 240 },
        { :name => 'entity',   :index => 'deal.entity.tag', :width => 230 },
        { :name => 'resource', :index => 'deal.give.tag',   :width => 230 },
        { :name => 'debit',    :index => 'debit',           :width => 50  },
        { :name => 'credit',   :index => 'credit',          :width => 50  }
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
