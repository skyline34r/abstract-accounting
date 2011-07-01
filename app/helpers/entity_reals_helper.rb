module EntityRealsHelper
  include JqgridsHelper

  def entity_real_jqgrid
    options = {:on_document_ready => true}

    grid = [{
      :url => '/entity_reals/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('entity.tag')],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 800 }
      ],
      :pager => '#entity_real_pager',
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
        $("#entity_real_tag").val($("#entity_real_list").getCell(cell, "tag"));
        $("#change_entity_real").removeAttr("disabled");
        $("#change_entity_real").parent().parent().attr("action",
            "/entity_reals/" + cell + "/edit");
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if (canSelectEntityReal) return true;
        return false;
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "entity_real_list");
      }'.to_json_var
    }]

    pager = [:navGrid,
             '#entity_real_pager',
             {:refresh => false, :add => false,
              :del=> false, :edit => false,
              :search => false, :view => false, :cloneToTop => true},
             {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search',
      :onClickButton => 'function() {
        if(filter) {
          $("#entity_real_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#entity_real_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find_bottom = [:navButtonAdd,
                                '#entity_real_pager',
                                button_find_data]
    pager_button_find_top = [:navButtonAdd,
                             '#entity_real_list_toppager_left',
                             button_find_data]

    jqgrid_api 'entity_real_list', grid, options, pager,
      pager_button_find_bottom, pager_button_find_top
  end
end