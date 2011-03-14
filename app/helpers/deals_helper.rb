module DealsHelper

  include JqgridsHelper

  def deals_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/deals',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'entity', 'rate', 'give', 'take', 'id', 'take.id',
                    'take.type'],
      :colModel => [
        { :name => 'tag',       :index => 'tag',             :width => 400 },
        { :name => 'entity',    :index => 'entity.tag',      :width => 400 },
        { :name => 'rate',      :index => 'rate',            :width => 5, :hidden => true },
        { :name => 'give',      :index => 'give.tag',        :width => 5, :hidden => true },
        { :name => 'take',      :index => 'take.tag',        :width => 5, :hidden => true },
        { :name => 'id',        :index => 'id',              :width => 5, :hidden => true },
        { :name => 'take.id',   :index => 'take.id',         :width => 5, :hidden => true },
        { :name => 'take.type', :index => 'take.class.name', :width => 5, :hidden => true }
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
        $('#deal_tag').val($('#deals_list').getCell(cell, 'tag'));
        $('#entity_tag').val($('#deals_list').getCell(cell, 'entity'));
        $('#give_tag').val($('#deals_list').getCell(cell, 'give'));
        $('#take_tag').val($('#deals_list').getCell(cell, 'take'));
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
