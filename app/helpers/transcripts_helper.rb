module TranscriptsHelper

  include JqgridsHelper

  def transcripts_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/transcripts',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['date', 'deal', 'debit', 'credit'],
      :colModel => [
        { :name => 'date',   :index => 'date',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'deal',   :index => 'deal',   :width => 400,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[2] == $("#choose_deal").val())
                             return rowObject[1];
                           return rowObject[2];
                         }'.to_json_var
        },
        { :name => 'debit',  :index => 'debit',  :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[1] == $("#choose_deal").val())
                           {
                             return (rowObject[3] * rowObject[4] / rowObject[3]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        },
        { :name => 'credit', :index => 'credit', :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[2] == $("#choose_deal").val())
                           {
                             return ((rowObject[4] + rowObject[5]) / rowObject[3]
                                     * rowObject[3]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        }
      ],
      :pager => '#transcripts_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :viewrecords => true
    }]

    jqgrid_api 'transcripts_list', grid, options

  end

end
