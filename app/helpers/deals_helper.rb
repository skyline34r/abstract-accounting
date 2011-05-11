module DealsHelper

  include JqgridsHelper

  def deals_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/deals/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'entity', 'rate', 'give', 'take', 'take.id',
                    'take.type', 'isOffBalance'],
      :colModel => [
        { :name => 'tag',          :index => 'tag',             :width => 400 },
        { :name => 'entity',       :index => 'entity.tag',      :width => 400 },
        { :name => 'rate',         :index => 'rate',            :width => 5, :hidden => true },
        { :name => 'give',         :index => 'give.tag',        :width => 5, :hidden => true },
        { :name => 'take',         :index => 'take.tag',        :width => 5, :hidden => true },
        { :name => 'take.id',      :index => 'take.id',         :width => 5, :hidden => true },
        { :name => 'take.type',    :index => 'take.class.name', :width => 5, :hidden => true },
        { :name => 'isOffBalance', :index => 'isOffBalance',    :width => 5, :hidden => true }
      ],
      :pager => '#deals_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true,
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

    jqgrid_api 'deals_list', grid, options

  end

end
