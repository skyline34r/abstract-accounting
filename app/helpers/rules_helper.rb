module RulesHelper

  include JqgridsHelper

  def rules_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :datatype => 'local',
      :colNames => [t('rule.tag'), 'to_id', t('rule.giveto'), 'from_id', t('rule.takefrom'), t('rule.rate'),
                    'change_side', 'fact_side'],
      :colModel => [ { :name => 'tag',         :index => 'tag',         :width => 300 },
                     { :name => 'to_id',       :index => 'to_id',       :hidden => true },
                     { :name => 'to_tag',      :index => 'to_tag',      :width => 200 },
                     { :name => 'from_id',     :index => 'from_id',     :hidden => true },
                     { :name => 'from_tag',    :index => 'from_tag',    :width => 200 },
                     { :name => 'rate',        :index => 'rate',        :width => 100 },
                     { :name => 'change_side', :index => 'change_side', :hidden => true },
                     { :name => 'fact_side',   :index => 'fact_side',   :hidden => true } ],
      :pager => '#rules_pager',
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
        ruleCellId = cell;
        $("#rule_tag").val($("#rules_list").getCell(cell, "tag"));
        $("#rule_to_id").val($("#rules_list").getCell(cell, "to_id"));
        $("#rule_to_tag").val($("#rules_list").getCell(cell, "to_tag"));
        $("#rule_from_id").val($("#rules_list").getCell(cell, "from_id"));
        $("#rule_from_tag").val($("#rules_list").getCell(cell, "from_tag"));
        $("#rule_rate").val($("#rules_list").getCell(cell, "rate"));
        $("#rule_on_off").removeAttr("checked");
        $("#rule_on_on").removeAttr("checked");
        $("#rule_off_off").removeAttr("checked");
        $("#rule_off_on").removeAttr("checked");

        if(($("#rules_list").getCell(cell, "change_side") == "true") &&
           ($("#rules_list").getCell(cell, "fact_side") == "false")) {
          $("#rule_on_off").attr("checked","checked");
        }
        if(($("#rules_list").getCell(cell, "change_side") == "true") &&
           ($("#rules_list").getCell(cell, "fact_side") == "true")) {
          $("#rule_on_on").attr("checked","checked");
        }
        if(($("#rules_list").getCell(cell, "change_side") == "false") &&
           ($("#rules_list").getCell(cell, "fact_side") == "false")) {
          $("#rule_off_off").attr("checked","checked");
        }
        if(($("#rules_list").getCell(cell, "change_side") == "false") &&
           ($("#rules_list").getCell(cell, "fact_side") == "true")) {
          $("#rule_off_on").attr("checked","checked");
        }
        if(!ruleView) $("#change_rule").removeAttr("disabled");
      }'.to_json_var,
      :beforeSelectRow => 'function()
      {
        if (canSelectRule) return true;
        return false;
      }'.to_json_var,
      :beforeRequest => 'function()
      {
        if(ruleView) {
          $("#rules_list").setGridParam({datatype: "json"});
          $("#rules_list").setGridParam({url: "/rules/data?deal_id=" + dealId});
        }
      }'.to_json_var,
      :onPaging => 'function(param)
      {
        fixPager(param, "rules_list");
      }'.to_json_var,
      :loadComplete => 'function()
      {
        if(editRowId != null) {
          if(jQuery.inArray(editRowId, $("#rules_list").getDataIDs()) >= 0) {
            $("#rules_list").setSelection(editRowId);
          }
        }
      }'.to_json_var
    }]

    pager = [:navGrid, '#rules_pager', {:refresh => false, :add => false,
                                        :del=> false, :edit => false,
                                        :search => false, :view => false, :cloneToTop => true},
                                       {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#rules_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#rules_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#rules_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#rules_list_toppager_left', button_find_data]

    jqgrid_api 'rules_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
