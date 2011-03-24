module EntitiesHelper

  include JqgridsHelper

  def entities_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        document.getElementById('entity_tag').value =
          $('#data_list').getCell(cell, 'tag');
        document.getElementById('change_entity').disabled = false;
        document.getElementById('change_entity').parentNode.parentNode.action =
          '/entities/' + cell + '/edit';
      }".to_json_var,
      :beforeSelectRow =>	"function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
    }]

    jqgrid_api 'data_list', grid, options

  end

end
