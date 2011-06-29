module UsersHelper

  include JqgridsHelper

  def users_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/users/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('user.email'), t('user.entity'), t('user.place'), 'role_ids'],
      :colModel => [
        { :name => 'email',    :index => 'email',    :width => 200 },
        { :name => 'entity',   :index => 'entity',   :width => 250 },
        { :name => 'place',    :index => 'place',    :width => 250 },
        { :name => 'role_ids', :index => 'role_ids', :width => 5, :hidden => true }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'email',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onSelectRow => "function(cell)
      {
        $('#user_email').val($('#data_list').getCell(cell, 'email'));
        $('#user_entity_tag').val($('#data_list').getCell(cell, 'entity'));
        $('#user_place_tag').val($('#data_list').getCell(cell, 'place'));
        if($('#data_list').getCell(cell, 'entity') == '') {
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
          checkRoles($('#data_list').getCell(cell, 'role_ids').split(','));
          roles = $('#data_list').getCell(cell, 'role_ids').split(',');
          entity_tag = $('#data_list').getCell(cell, 'entity');
          place_tag = $('#data_list').getCell(cell, 'place');
        }
      }".to_json_var,
      :beforeSelectRow => "function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "data_list");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          $("#data_list").setSelection(editRowId);
          editRowId = null;
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#data_pager', {:refresh => false, :add => false,
                                       :del=> false, :edit => false,
                                       :search => false, :view => false, :cloneToTop => true},
                                      {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#data_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#data_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#data_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#data_list_toppager_left', button_find_data]

    jqgrid_api 'data_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
