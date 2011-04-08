module RulesHelper

  include JqgridsHelper

  def rules_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :datatype => 'local',
      :colNames => ['tag', 'to_id', 'to_tag', 'from_id', 'from_tag', 'rate',
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
      :viewrecords => true,
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
        $("#change_rule").removeAttr("disabled");
      }'.to_json_var
    }]

    jqgrid_api 'rules_list', grid, options

  end

end
