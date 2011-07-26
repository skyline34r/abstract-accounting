module EntitiesHelper

  include JqgridsHelper

  def entities_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/entities/view?columns=full',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('entity.tag'), t('entity.real')],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 400 },
        { :name => 'real',  :index => 'real',   :width => 400 }
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
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          $("#entity_list").setSelection(editRowId);
          editRowId = null;
        }
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

  def check_entities_jqgrid(data_url)
    options = {:on_document_ready => true}

    grid = [{
      :url => data_url,
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('entity.tag'), ''],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.tag != undefined)
                             return rowObject.tag;
                           return rowObject[0];
                         }'.to_json_var },
        { :name => 'empty', :index => 'empty', :hidden => true,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.empty != undefined)
                             return rowObject.empty;
                           return rowObject[1];
                         }'.to_json_var}
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

    if @with_check
      grid[0][:colNames].insert(0, '')
      grid[0][:colModel].insert(0, { :name => 'check', :index => 'check',
                                     :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           var checked = "";
                           if (firstOpen) {
                             if (rowObject[1] == false) {
                               getPageSessionData(crossPage, "surrogates")[options.rowId.toString()] = rowObject;
                               getPageSessionData(crossPage, "base_surrogates")[options.rowId.toString()] = rowObject;
                               checked = "checked";
                             }
                           } else if (options.rowId.toString() in getPageSessionData(crossPage, "surrogates")) {
                             checked = "checked";
                           }
                           return "<input type=\'checkbox\' id=\'check_" +
                             options.rowId + "\' onClick=\'onRowChecked(\""
                             + options.rowId + "\");\' " + checked + ">";
                         }'.to_json_var })
      grid[0][:loadComplete] = 'function(data)
      {
        entityListIDs = $("#entity_list").getDataIDs();
        surrogates = getPageSessionData(crossPage, "surrogates");
        for (var id in surrogates) {
          if (entityListIDs.indexOf(id) >= 0) {
            $("#entity_list").delRowData(id);
          }
          $("#entity_list").addRowData(id, {"tag": surrogates[id].tag, "empty": surrogates[id].empty}, "first");
        }
        if (firstOpen) {
          firstOpen = false;
        }
      }'.to_json_var
    end

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
