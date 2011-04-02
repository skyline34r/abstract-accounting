module ResourcesHelper

  include JqgridsHelper

  def resources_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/resources/view',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['tag', 'type', 'id', 'code'],
      :colModel => [
        { :name => 'tag',  :index => 'tag',   :width => 700 },
        { :name => 'type', :index => 'class',  :width => 100 },
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true },
        { :name => 'code', :index => 'num_code',  :width => 5, :hidden => true }
      ],
      :pager => '#resources_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :sortname => 'tag',
      :sortorder => 'asc',
      :viewrecords => true,
      :onSelectRow => 'function(cell)
      {
        $("#resource_tag").val($("#resources_list").getCell(cell, "tag"));
        $("#change_resource").removeAttr("disabled");
        selResId = $("#resources_list").getCell(cell, "id");
        if($("#resources_list").getCell(cell, "type") == "Asset")
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

    jqgrid_api 'resources_list', grid, options

  end

end
