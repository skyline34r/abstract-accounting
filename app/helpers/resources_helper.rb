module ResourcesHelper

  include JqgridsHelper

  def resources_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/resources/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('resource.tag'), t('resource.type'), 'id', 'code'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 700 },
        { :name => 'type', :index => 'type',  :width => 100, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return getResType(cellvalue);
                         }'.to_json_var  },
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true },
        { :name => 'code', :index => 'num_code',  :width => 5, :hidden => true }
      ],
      :pager => '#resources_pager',
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
        $("#resource_tag").val($("#resources_list").getCell(cell, "tag"));
        $("#change_resource").removeAttr("disabled");
        selResId = $("#resources_list").getCell(cell, "id");
        if($("#resources_list").getCell(cell, "type") == getResType("Asset"))
        {
          $("#change_resource").parent().parent().attr("action",
            "/resources/" + selResId + "/edit_asset");
          $("#resource_type").removeAttr("checked");
          $("#div_money_code").css("display","none");
        }
        else
        {
          $("#change_resource").parent().parent().attr("action",
            "/resources/" + selResId + "/edit_money");
          $("#resource_type").attr("checked","checked");
          $("#div_money_code").css("display","block");
          $("#money_code").val($("#resources_list").getCell(cell, "code"));
        }
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if(canSelectResource) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "resources_list");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          $("#resources_list").setSelection(editRowId);
          editRowId = null;
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#resources_pager', {:refresh => false, :add => false,
                                            :del=> false, :edit => false,
                                            :search => false, :view => false, :cloneToTop => true},
                                           {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#resources_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#resources_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#resources_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#resources_list_toppager_left', button_find_data]

    jqgrid_api 'resources_list', grid, options, pager, pager_button_find, pager_button_find1

  end

  def check_assets_jqgrid(data_url)
    options = {:on_document_ready => true}

    grid = [{
      :url => data_url,
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('resource.tag'), ''],
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
      :pager => '#asset_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :beforeSelectRow =>	'function()
      {
        if (canSelectAsset) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "asset_list");
      }'.to_json_var
    }]

    if @with_check
      grid[0][:colNames].insert(0, '')
      grid[0][:colModel].insert(0, { :name => '', :index => 'check',
                                     :width => 14, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           var checked = "";
                           if (firstOpen) {
                             if (rowObject[1] == false) {
                               getPageSessionData(crossPage, "surrogates")[options.rowId.toString()] = true;
                               getPageSessionData(crossPage, "base_surrogates")[options.rowId.toString()] = true;
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
        if (firstOpen) {
          firstOpen = false;
        }
      }'.to_json_var
    end

    pager = [:navGrid, '#asset_pager', {:refresh => false, :add => false,
                                         :del=> false, :edit => false,
                                         :search => false, :view => false, :cloneToTop => true},
                                        {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#asset_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#asset_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#asset_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#asset_list_toppager_left', button_find_data]

    jqgrid_api 'asset_list', grid, options, pager, pager_button_find, pager_button_find1
  end

end
