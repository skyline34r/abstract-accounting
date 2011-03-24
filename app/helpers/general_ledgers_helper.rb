module GeneralLedgersHelper

  include JqgridsHelper

  def general_ledgers_jqgrid

    options = {:on_document_ready => true}

    grid = [{
      :url => '/general_ledgers',
      :datatype => 'json',
      :mtype => 'GET',
      :colNames => ['date', 'resource', 'quantity', 'DC', 'deal', 'price',
                    'debit', 'credit'],
      :colModel => [
        { :name => 'date',     :index => 'fact.day',          :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           return cellvalue.substr(0,10);
                         }'.to_json_var
        },
        { :name => 'resource', :index => 'fact.resource.tag', :width => 100 },
        { :name => 'quantity', :index => 'fact.amount',       :width => 100 },
        { :name => 'DC',       :index => 'DC',                :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (cellvalue == "debit") return cellvalue;
                           return "credit";
                         }'.to_json_var
        },
        { :name => 'deal', :index => 'deal',                  :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.deal) return rowObject.deal;
                           return rowObject[3];
                         }'.to_json_var
        },
        { :name => 'price', :index => 'price',                :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject[2] == 0) return "0";
                           if (rowObject.price) return rowObject.price;
                           return ((rowObject[5] + rowObject[6]) / rowObject[2]).toFixed(2);
                         }'.to_json_var
        },
        { :name => 'debit', :index => 'debit',                :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.debit) return rowObject.debit;
                           return "";
                         }'.to_json_var
        },
        { :name => 'credit', :index => 'credit',              :width => 100,
          :formatter => 'function(cellvalue, options, rowObject) {
                           if (rowObject.credit) return "";
                           return ((rowObject[5] + rowObject[6]) / rowObject[2]
                                   * rowObject[2]).toFixed(2);
                         }'.to_json_var
        }
      ],
      :pager => '#data_pager',
      :rowNum => 10,
      :rowList => [10, 20, 30],
      :viewrecords => true,
      :afterInsertRow => 'function(rowid, rowdata, rowelem)
      {
         function getPrice() {
           if (rowelem[2] == 0) return "0";
           return (rowelem[5] / rowelem[2]).toFixed(2);
         }
         function getDebit() {
           return (rowelem[2] * rowelem[5] / rowelem[2]).toFixed(2);
         }
         if (rowid != "sub") {
           $("#data_list").addRowData("sub", { date: "",
                                               resource: "",
                                               quantity: "",
                                               DC: "debit",
                                               deal: rowelem[4],
                                               price: getPrice(),
                                               debit: getDebit(),
                                               credit: "null" });
         }
      }'.to_json_var
    }]
    
    jqgrid_api 'data_list', grid, options

  end

end
