module RolesHelper

  include JqgridsHelper

  def roles_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/roles/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('role.name'), 'pages'],
      :colModel => [
        { :name => 'name',  :index => 'name',   :width => 800 },
        { :name => 'pages', :index => 'pages',  :width => 5, :hidden => true }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'name',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onSelectRow => "function(cell)
      {
        $('#role_name').val($('#data_list').getCell(cell, 'name'));
        if($('#data_list').getCell(cell, 'name') == 'admin') {
          $('#change_role').attr('disabled','disabled');
          $('#pages').css('display','none');
        } else {
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
        }
      }".to_json_var,
      :beforeSelectRow => "function()
      {
        if (canSelect) return true;
        return false;
      }".to_json_var
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
