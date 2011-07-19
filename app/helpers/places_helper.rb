module PlacesHelper

  include JqgridsHelper

  def places_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/places/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('place.tag')],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#place_pager',
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
        $("#place_tag").val($("#place_list").getCell(cell, "tag"));
        $("#change_place").removeAttr("disabled");
        $("#change_place").parent().parent().attr("action",
            "/places/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectPlace) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "place_list");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          $("#place_list").setSelection(editRowId);
          editRowId = null;
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#place_pager', {:refresh => false, :add => false,
                                        :del=> false, :edit => false,
                                        :search => false, :view => false, :cloneToTop => true},
                                       {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#place_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#place_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#place_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#place_list_toppager_left', button_find_data]

    jqgrid_api 'place_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
