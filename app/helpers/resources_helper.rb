module ResourcesHelper

  include JqgridsHelper

  def resources_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/resources',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'type', 'id'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 700 },
        { :name => 'type',  :index => 'type',   :width => 100 },
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true }
      ],
      :pager => '#resources_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        $('#resource_tag').val(cell);
        $('#change_resource').removeAttr('disabled');
        if($('#resources_list').getCell(cell, 'type') == 'asset')
        {
          $('#change_resource').parent().parent().attr('action',
            '/resources/edit_asset.' + $('#resources_list').getCell(cell, 'id'));
          $('#resource_type').removeAttr('checked');
        }
        else
        {
          $('#change_resource').parent().parent().attr('action',
            '/resources/edit_money.' + $('#resources_list').getCell(cell, 'id'));
          $('#resource_type').attr('checked','checked');
        }
      }".to_json_var
    }]

    jqgrid_api 'resources_list', grid, options

  end

end
