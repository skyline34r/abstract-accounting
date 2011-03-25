module TranscriptsHelper

  include JqgridsHelper

  def transcripts_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/transcripts/load?empty=true',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['id', 'date', 'deal', 'debit', 'credit', 'debit', 'credit'],
      :colModel => [
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true },
        { :name => 'date',   :index => 'date',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'deal',   :index => 'deal',   :width => 400,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                             return rowObject[2];
                           return rowObject[3];
                         }'.to_json_var
        },
        { :name => 'debit',  :index => 'debit',  :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                           {
                             return (rowObject[4]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        },
        { :name => 'credit', :index => 'credit', :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[2] == $("#choose_deal").val())
                           {
                             return (rowObject[4]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        },
        { :name => 'h_debit',  :index => 'h_debit',  :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                           {
                             return (rowObject[5] + rowObject[6]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var,
          :hidden => true
        },
        { :name => 'h_credit', :index => 'h_credit', :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[2] == $("#choose_deal").val())
                           {
                             return (rowObject[5]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var,
          :hidden => true
        }
      ],
      :pager => '#transcripts_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :viewrecords => true,
      :shrinkToFit => false
    }]

    jqgrid_api 'transcripts_list', grid, options

  end

end
