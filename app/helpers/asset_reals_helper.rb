module AssetRealsHelper
  include JqgridsHelper

  def asset_real_jqgrid
    options = {:on_document_ready => true}

    grid = [{
      :url => '/asset_reals/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('resource.tag'), ''],
      :colModel => [
        { :name => 'tag', :index => 'tag', :width => 800 },
        { :name => 'empty', :index => 'empty', :hidden => true }
      ],
      :pager => '#asset_real_pager',
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
        $("#asset_real_tag").val($("#asset_real_list").getCell(cell, "tag"));
        setPageSessionData("asset_reals", "base_tag",
            $("#asset_real_list").getCell(cell, "tag"));
        $("#change_asset_real").removeAttr("disabled");
        if ($("#asset_real_list").getCell(cell, "empty") == "false") {
          $("#asset_real_choose").removeAttr("disabled");
        } else {
          $("#asset_real_choose").attr("disabled", "disabled");
        }
        $("#asset_real_choose").unbind("click");
        $("#asset_real_choose").click(function() {
          assetRealChooseSurrogates(cell);
        });
        $("#change_asset_real").parent().parent().attr("action",
            "/asset_reals/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectAssetReal) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "asset_real_list");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          $("#asset_real_list").setSelection(editRowId);
          editRowId = null;
        }
      }'.to_json_var
    }]

    pager = [:navGrid,
             '#asset_real_pager',
             {:refresh => false, :add => false,
              :del=> false, :edit => false,
              :search => false, :view => false, :cloneToTop => true},
             {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search',
      :onClickButton => 'function() {
        if(filter) {
          $("#asset_real_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#asset_real_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find_bottom = [:navButtonAdd,
                                '#asset_real_pager',
                                button_find_data]
    pager_button_find_top = [:navButtonAdd,
                             '#asset_real_list_toppager_left',
                             button_find_data]

    jqgrid_api 'asset_real_list', grid, options, pager,
      pager_button_find_bottom, pager_button_find_top
  end
end
