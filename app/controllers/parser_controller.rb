class ParserController < ApplicationController  
  def index
    @games = {'ios' => 'iOS', 'and' => 'Android', 'mac' => 'Mac', 
              'exp' => 'CTR Experiments', 'hg' => 'CTR: Holiday Gift', 
              'andexp' => 'Experiments And' }
    @languages = %w(EN RU FR DE KO ZH JA ES IT NL BR)

    if params[:xls].present?
      xls = Spreadsheet.open params[:xls].tempfile
      sheet = xls.worksheet 'CTR Strings'
      
      @game_id = params[:game][:id]
      @langs = params[:game][:langs].delete_if{ |l| l.blank? }
      @file_langs = {}
      lang_ex = /\((..)\)/
      
      sheet.row(0).each_with_index do |r,i| 
        if i > 2 and r.present?
          lang = lang_ex.match(r)[1]
          @file_langs[i] = lang if @langs.include? lang
        end
      end
      
      sheet.each_with_index{ |row, i| (@rows ||= []) << row if i > 0 and row.present? }
      
      @errors = check_xls(@rows)
      
      if @rows.present?
        xml_str  = render_to_string(:file => 'parser/results.xml.builder').to_str
        @xml = File.open('tmp/parser.xml', 'w') {|f| f.write(xml_str) }
      end
    end
    
    render :file => 'parser/index.html', :layout => 'application', :content_type => 'text/html'
  end
  
  def download
    xml = File.read("#{Rails.root}/tmp/parser.xml")
    
    send_data xml, :filename => "parser.xml",
                   :type => 'text/xml',
                   :disposition => 'attachment'
  end
  
private

  def check_xls(rows)
    errors = []
    rows.each_with_index do |row, y|
      if row[1].present? and row[1].include? @game_id
        limit = row[2].to_i
        @file_langs.each do |x, lang|
          cell = row[x]
          if cell.blank?
            errors << "Cell #{(x + 65).chr}#{y + 3} -- cell is blank"
          elsif limit > 0 and limit < cell.length
            errors << "Cell #{(x + 65).chr}#{y + 3} -- \"#{cell}\", #{cell.length} chars -- over limit (#{limit})"
          end
        end
      end
    end
    
    errors
  end
  
end
