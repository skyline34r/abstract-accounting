module QuotesHelper

  include JqgridsHelper

  def quotes_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/quotes',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['money_tag', 'day', 'rate', 'id', 'money_id'],
      :colModel => [
        { :name => 'money_tag', :index => 'money_tag', :width => 400 },
        { :name => 'day',       :index => 'day',       :width => 200 },
        { :name => 'rate',      :index => 'rate',      :width => 200 },
        { :name => 'id',        :index => 'id',        :width => 5, :hidden => true },
        { :name => 'money_id',  :index => 'money_id',  :width => 5, :hidden => true }
      ],
      :pager => '#quotes_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'resource',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'quotes_list', grid, options

  end

end
