module ParserHelper
  def string_id(row)
    row[0] || (row[3].to_s.split(' ')*'_').upcase[0..12]
  end
  
  def row_for_game?(row,game_id)
    row[1].present? and (row[1] == '*' || row[1].gsub(/[ ]+/, '').split(',').include?(@game_id))
  end
end
