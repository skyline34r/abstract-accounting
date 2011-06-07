module DealsHelper

  include JqgridsHelper

  def deals_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/deals/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => [t('deal.tag'), t('deal.entity'), 'rate', 'give', 'take', 'take_id',
                    'take_type', 'isOffBalance'],
      :colModel => [
        { :name => 'tag',          :index => 'tag',          :width => 400 },
        { :name => 'entity',       :index => 'entity',       :width => 400 },
        { :name => 'rate',         :index => 'rate',         :width => 5, :hidden => true },
        { :name => 'give',         :index => 'give',         :width => 5, :hidden => true },
        { :name => 'take',         :index => 'take',         :width => 5, :hidden => true },
        { :name => 'take_id',      :index => 'take_id',      :width => 5, :hidden => true },
        { :name => 'take_type',    :index => 'take_type',    :width => 5, :hidden => true },
        { :name => 'isOffBalance', :index => 'isOffBalance', :width => 5, :hidden => true }
      ],
      :pager => '#deals_pager',
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
        $("#dir_0").removeAttr("disabled");
        $("#dir_1").removeAttr("disabled");
        $("#deal_rules").removeAttr("disabled");
        $("#deal_tag").val($("#deals_list").getCell(cell, "tag"));
        $("#deal_entity_tag").val($("#deals_list").getCell(cell, "entity"));
        $("#deal_give_tag").val($("#deals_list").getCell(cell, "give"));
        $("#deal_take_tag").val($("#deals_list").getCell(cell, "take"));
        $("#deal_rate").val($("#deals_list").getCell(cell, "rate"));
        $("#dir_0").attr("checked","checked");
        if($("#deals_list").getCell(cell, "isOffBalance") == "true") {
          $("#isOfBalance").attr("checked","checked");
        } else {
          $("#isOfBalance").removeAttr("checked");
        }
      }'.to_json_var,
      :beforeSelectRow =>	'function()
      {
        if(canSelectDeal) return true;
        return false;
      }'.to_json_var,
      :beforeRequest => 'function()
      {
        $("#deal_rules").attr("disabled", "disabled");
      }'.to_json_var
    }]

    pager = [:navGrid, '#deals_pager', {:refresh => false, :add => false,
                                        :del=> false, :edit => false,
                                        :search => false, :view => false, :cloneToTop => true},
                                       {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#deals_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#deals_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#deals_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#deals_list_toppager_left', button_find_data]

    jqgrid_api 'deals_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
