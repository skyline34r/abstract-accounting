module RulesHelper

  include JqgridsHelper

  def rules_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :datatype => 'local',
      :colNames => ['id', 'tag', 'to_id', 'to_tag', 'from_id', 'from_tag',
                    'rate', 'fact_side', 'change_side'],
      :colModel => [ { :name => 'id',          :index => 'id',          :hidden => true },
                     { :name => 'tag',         :index => 'tag',         :width => 300 },
                     { :name => 'to_id',       :index => 'to_id',       :hidden => true },
                     { :name => 'to_tag',      :index => 'to_tag',      :width => 200 },
                     { :name => 'from_id',     :index => 'from_id',     :hidden => true },
                     { :name => 'from_tag',    :index => 'from_tag',    :width => 200 },
                     { :name => 'rate',        :index => 'rate',        :width => 100 },
                     { :name => 'fact_side',   :index => 'fact_side',   :hidden => true },
                     { :name => 'change_side', :index => 'change_side', :hidden => true }],
      :pager => '#rules_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true
    }]

    jqgrid_api 'rules_list', grid, options

  end

end
