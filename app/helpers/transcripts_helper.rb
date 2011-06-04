module TranscriptsHelper

  include JqgridsHelper

  def transcripts_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/transcripts/load?empty=true',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['id', t('transcript.transcriptList.date'),
                          t('transcript.transcriptList.deal'),
                          t('transcript.transcriptList.debit'),
                          t('transcript.transcriptList.credit'),
                          t('transcript.transcriptList.debit'),
                          t('transcript.transcriptList.credit')],
      :colModel => [
        { :name => 'id',   :index => 'id',    :width => 5, :hidden => true },
        { :name => 'date',   :index => 'date',   :width => 200,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'deal',   :index => 'deal',   :width => 400, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                             return rowObject[2];
                           return rowObject[3];
                         }'.to_json_var
        },
        { :name => 'debit',  :index => 'debit',  :width => 100, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                           {
                             return (rowObject[4]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        },
        { :name => 'credit', :index => 'credit', :width => 100, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[2] == $("#choose_deal").val())
                           {
                             return (rowObject[4]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var
        },
        { :name => 'h_debit',  :index => 'h_debit',  :width => 100, :search => false,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if(rowObject[3] == $("#choose_deal").val())
                           {
                             return (rowObject[5] + rowObject[6]).toFixed(2);
                           }
                           return "";
                         }'.to_json_var,
          :hidden => true
        },
        { :name => 'h_credit', :index => 'h_credit', :width => 100, :search => false,
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
      :height => "100%",
      :viewrecords => true,
      :gridview => true,
      :toppager => true,
      :shrinkToFit => true
    }]

    pager = [:navGrid, '#transcripts_pager', {:refresh => false, :add => false,
                                              :del=> false, :edit => false,
                                              :search => false, :view => false, :cloneToTop => true},
                                             {}, {}, {}]

    button_find_data = {
      :caption => t('grid.btn_find'),
      :buttonicon => 'ui-icon-search', :onClickButton => 'function() {
        if(filter) {
          $("#transcripts_list")[0].clearToolbar();
          filter = false;
        } else {
          filter = true;
        }
        $("#transcripts_list")[0].toggleToolbar();
      }'.to_json_var }

    pager_button_find = [:navButtonAdd, '#transcripts_pager', button_find_data]
    pager_button_find1 = [:navButtonAdd, '#transcripts_list_toppager_left', button_find_data]

    jqgrid_api 'transcripts_list', grid, options, pager, pager_button_find, pager_button_find1

  end

end
