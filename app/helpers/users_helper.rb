module UsersHelper

  include JqgridsHelper

  def users_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/users',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['email', 'role_ids', 'id'],
      :colModel => [
        { :name => 'email',    :index => 'email',    :width => 800 },
        { :name => 'role_ids', :index => 'role_ids', :width => 5, :hidden => true },
        { :name => 'id',       :index => 'id',       :width => 5, :hidden => true }
      ],
      :pager => '#users_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'email',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        $('#user_email').val(cell);
        $('#change_user').removeAttr('disabled');
        $('#change_user').parent().parent().attr('action',
            '/users/' + $('#users_list').getCell(cell, 'id') + '/edit');
        var arr_ids = $('#users_list').getCell(cell, 'role_ids').split(',');
        var i = 1;
        while($('#user_role_id_' + i).val())
        {
          $('#user_role_id_' + i).removeAttr('checked');
          i++;
        }
        i = 0;
        while(arr_ids[i])
        {
          $('#user_role_id_' + arr_ids[i]).attr('checked', 'checked');
          i++;
        }
      }".to_json_var,
      :beforeSelectRow => "function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
    }]

    jqgrid_api 'users_list', grid, options

  end

end
