xml.instruct! :xml, :version => "1.0"
xml.strings :locales => @file_langs.values.map{|l| l.downcase} * ',' do
  @rows.each do |row|
    if row_for_game?(row, @game_id)
      xml.string :name => string_id(row) do
        @file_langs.each{ |index, lang| xml.tag! lang.downcase, row[index] }
      end
    end
  end
end
