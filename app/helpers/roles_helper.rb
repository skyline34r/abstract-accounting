module RolesHelper

  include JqgridsHelper

  def roles_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/roles/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['name', 'pages'],
      :colModel => [
        { :name => 'name',  :index => 'name',   :width => 800 },
        { :name => 'pages', :index => 'pages',  :width => 5, :hidden => true }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'name',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        $('#role_name').val($('#data_list').getCell(cell, 'name'));
        $('#change_role').removeAttr('disabled');
        $('#change_role').parent().parent().attr('action',
            '/roles/' + cell + '/edit');
        uncheckPages();
        var pages = $('#data_list').getCell(cell, 'pages').split(',');
        for(var i=0; i<pages.length; i++)
        {
          $('[name=' + pages[i] + ']').attr('checked', 'checked');
        }
        $('#pages').css('display','block');
      }".to_json_var,
      :beforeSelectRow => "function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
    }]

    jqgrid_api 'data_list', grid, options

  end

end
