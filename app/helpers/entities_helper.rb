module EntitiesHelper

  include JqgridsHelper

  def entities_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('entity.tag')],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#entity_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onSelectRow => 'function(cell)
      {
        $("#entity_tag").val($("#entity_list").getCell(cell, "tag"));
        $("#change_entity").removeAttr("disabled");
        $("#change_entity").parent().parent().attr("action",
            "/entities/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectEntity) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "entity_list");
      }'.to_json_var
    }]

    pager = [:navGrid, '#entity_pager', {:refresh => false, :add => false,
                                         :del=> false, :edit => false,
                                         :search => false, :view => false, :cloneToTop => true},
                                        {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#entity_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#entity_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#entity_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#entity_list_toppager_left', button_find_data]

    jqgrid_api 'entity_list', grid, options, pager, pager_button_find, pager_button_find1

  end

  def check_entities_jqgrid
    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['', t('entity.tag')],
      :colModel => [
        { :name => '', :index => 'check', :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           var checked = "";
                           if (options.rowId.toString() in entityCheckedData)
                           {
                             checked = "checked"
                           }
                           return "<input type=\'checkbox\' id=\'check_" +
                             options.rowId + "\' onClick=\'onRowChecked(\""
                             + options.rowId + "\");\' " + checked + ">";
                         }'.to_json_var },
        { :name => 'tag',  :index => 'tag',   :width => 800,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return rowObject[0];
                         }'.to_json_var }
      ],
      :pager => '#entity_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :onSelectRow => 'function(cell)
      {
        $("#entity_tag").val($("#entity_list").getCell(cell, "tag"));
        $("#change_entity").removeAttr("disabled");
        $("#change_entity").parent().parent().attr("action",
            "/entities/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectEntity) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "entity_list");
      }'.to_json_var
    }]

    pager = [:navGrid, '#entity_pager', {:refresh => false, :add => false,
                                         :del=> false, :edit => false,
                                         :search => false, :view => false, :cloneToTop => true},
                                        {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#entity_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#entity_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#entity_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#entity_list_toppager_left', button_find_data]

    jqgrid_api 'entity_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
