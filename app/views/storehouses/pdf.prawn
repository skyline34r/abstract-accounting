pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
pdf.text 'Place:    ' + @place
pdf.text 'Owner:  ' + @owner
pdf.text 'Date:  ' + @date
pdf.text 'To:  ' + @to

pdf.table(@table_values,
          :font_size => 16,
          :horizontal_padding => 5,
          :vertical_padding => 3,
          :border_width => 2,
          :position => :center,
          :row_colors => ['ffffff','ffffbb'],
          :headers => @table_headers)