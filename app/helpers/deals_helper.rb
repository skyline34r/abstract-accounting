module DealsHelper

  include JqgridsHelper

  def deals_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/deals',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'entity', 'id', 'rate', 'entity_id', 'give_id',
                    'give_type', 'take_id', 'take_type'],
      :colModel => [
        { :name => 'tag',       :index => 'tag',        :width => 400 },
        { :name => 'entity',    :index => 'entity_tag', :width => 400 },
        { :name => 'id',        :index => 'id',         :width => 5, :hidden => true },
        { :name => 'rate',      :index => 'rate',       :width => 5, :hidden => true },
        { :name => 'entity_id', :index => 'entity_id',  :width => 5, :hidden => true },
        { :name => 'give_id',   :index => 'give_id',    :width => 5, :hidden => true },
        { :name => 'give_type', :index => 'give_type',  :width => 5, :hidden => true },
        { :name => 'take_id',   :index => 'take_id',    :width => 5, :hidden => true },
        { :name => 'take_type', :index => 'take_type',  :width => 5, :hidden => true }
      ],
      :pager => '#deals_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'deals_list', grid, options

  end

end
