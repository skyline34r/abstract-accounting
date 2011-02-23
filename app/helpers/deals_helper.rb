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
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        $('#dir_0').removeAttr('disabled');
        $('#dir_1').removeAttr('disabled');
        $('#deal_tag').val(cell);
        $('#entity_tag').val($('#deals_list').getCell(cell, 'entity'));
        getResourceTag($('#deals_list').getCell(cell, 'give_id'),
                       $('#deals_list').getCell(cell, 'give_type'),
                       'give');
        getResourceTag($('#deals_list').getCell(cell, 'take_id'),
                       $('#deals_list').getCell(cell, 'take_type'),
                       'take');
        $('#deal_rate').val($('#deals_list').getCell(cell, 'rate'));
        $('#dir_0').attr('checked', 'checked');
      }".to_json_var,
      :beforeSelectRow =>	"function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
    }]

    jqgrid_api 'deals_list', grid, options

  end

end
