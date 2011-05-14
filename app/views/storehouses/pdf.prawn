pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width => pdf.bounds.width do
  pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width => pdf.bounds.width / 2 do
    pdf.text 'Date'
    pdf.text 'Place'
    pdf.text 'Owner'
    pdf.text 'To'
  end
  pdf.bounding_box [pdf.bounds.left + pdf.bounds.width / 2, pdf.bounds.top], :width => pdf.bounds.width / 2 do
    pdf.text @date
    pdf.text @place
    pdf.text @owner
    pdf.text @to
  end
end
pdf.move_down 10
pdf.bounding_box [pdf.bounds.left, pdf.cursor], :width => pdf.bounds.width do
  x_width = pdf.bounds.width / 5
  pdf.table [@header] + @row, :header => true, :column_widths => [x_width*3,x_width,x_width] do
    row(0).style(:font => "Times-Roman", :font_style => :bold, :background_color => 'cccccc')
  end
  pdf.bounding_box [pdf.bounds.left, pdf.cursor], :width => pdf.bounds.width do
    pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width => pdf.bounds.width / 3 do
      pdf.move_down 20
      pdf.text DateTime.now.to_date.to_s
      pdf.move_down 20
      pdf.text DateTime.now.to_date.to_s
    end
    pdf.bounding_box [pdf.bounds.left + pdf.bounds.width / 3, pdf.bounds.top], :width => (2 * pdf.bounds.width) / 3 do
      pdf.move_down 20
      pdf.text "_____________________________/" + @owner + "/"
      pdf.move_down 20
      pdf.text "_____________________________/" + @to + "/"
    end
  end
end