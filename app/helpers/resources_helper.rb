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

end
