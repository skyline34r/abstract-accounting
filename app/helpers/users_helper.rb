module UsersHelper

  include JqgridsHelper

  def users_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/users/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['email', 'entity', 'role_ids'],
      :colModel => [
        { :name => 'email',    :index => 'email',      :width => 400 },
        { :name => 'entity',   :index => 'entity.tag', :width => 400 },
        { :name => 'role_ids', :index => 'role_ids', :width => 5, :hidden => true }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'email',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => "function(cell)
      {
        $('#user_email').val($('#data_list').getCell(cell, 'email'));
        $('#user_entity_tag').val($('#data_list').getCell(cell, 'entity'));
        if($('#data_list').getCell(cell, 'email') == 'root@mail.com') {
          $('#change_user').attr('disabled','disabled');
          $('#change_user_pass').attr('disabled','disabled');
          $('#roles').css('display','none');
        } else {
          $('#change_user').removeAttr('disabled');
          $('#change_user_pass').removeAttr('disabled');
          $('#roles').css('display','block');
          $('#change_user').parent().parent().attr('action',
              '/users/' + cell + '/edit');
          $('#change_user_pass').parent().parent().attr('action',
              '/users/' + cell + '/edit');
          uncheckRoles();
          var arr_ids = $('#data_list').getCell(cell, 'role_ids').split(',');
          for(var i=0; i<arr_ids.length; i++)
          {
            $('#user_role_id_' + arr_ids[i]).attr('checked', 'checked');
          }
        }
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
