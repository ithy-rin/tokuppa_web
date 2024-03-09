#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')
    if edit == 'true'
        h_t = '編集'
    else
        h_t = '登録'
    end

    cd_data = []

 
    campaign_map = {"j_m_id" => "INTEGER", "j_m_name" => "TEXT", "map_url" => "TEXT", "start" => "DATETIME", "end" => "DATETIME", "note" => "TEXT"}
    campaign_index = ["j_m_id", "j_m_name", "map_url", "start", "end", "note"]
    campaign_ja = ["id", "表示名", "マップ", "表示開始日", "表示終了日", "備考"]


    way_l = [["per", "mai", "yen", "loto", "else_a"], ["back", "biki", "else_b"], ["plus", "only", "else_c"]]
    way_ja = {"per" => "?% 割合を小数表記で①に入力", "mai" => "?円毎に?p ①, ②", "yen" => "?円引き、還元 ①", "loto" => "抽選 期待値があれば①に入力", "back" => "後から還元", "biki" => "即時割引", "plus" => "他のにプラスして還元", "only" => "0%からプラスして還元", "else_a" => "割引その他", "else_b" => "還元方法その他", "else_c" => "計算方法その他"}
    way_p = ["割引方法", "還元方法", "計算方法"]
    
    new_map = {}
    for i in 0..campaign_index.length-1 do
        new_map[campaign_index[i]] = (cgi[campaign_index[i]] || '')
    end
    form_html = '<form action="/app/edit/jichitai_map_update.rb" method="post">'
    form_html += '<input type="hidden" name="edit" value='+edit+'>'
    

    for i in 0..campaign_index.length-1 do
        index = campaign_index[i]
        if index == 'j_m_id'
            form_html += '<input type="hidden" name='+index+' value='+new_map[index]+'>'
        elsif index=='card_id'
            form_html += ''
        elsif index == 'entry'
            form_html += "<p>エントリー:<select name=entry>"
            form_html += "<option value=>不要</option>"
            form_html += "<option value=need>必要</option>"
            form_html += "</select></p>"
        #手法選択
        elsif index == 'way'
            form_html += '<input type="hidden" name='+index+' value='+new_map[index]+'>'
            for j in 0..way_l.length-1 do
                form_html += "<p>"+way_p[j]+" 必須:<select name=way_"+j.to_s+">"
                for k in 0..way_l[j].length-1 do
                    if new_map[index].include?(way_l[j][k])
                        form_html += "<option value="+way_l[j][k]+" selected>"+way_ja[way_l[j][k]]+"</option>"
                    else
                        form_html += "<option value="+way_l[j][k]+">"+way_ja[way_l[j][k]]+"</option>"
                    end
                end
                form_html += "</select></p>"
            end
            
        elsif campaign_map[index] == "TEXT"
            form_html += '<p>'+campaign_ja[i]+':<input type="text" name='+index+' value='+new_map[index]+'></p>'
        elsif campaign_map[index] == "TEXTAREA"
            form_html += '<p>'+campaign_ja[i]+':<textarea rows="4" cols="40" name='+index+'>'+new_map[index]+'</textarea></p>'
        elsif campaign_map[index] == "INTEGER"
            if new_map[index] == ""
                form_html += '<p>'+campaign_ja[i]+':<input type="number" name='+index+'></p>'
            else
                form_html += '<p>'+campaign_ja[i]+':<input type="number" name='+index+' value='+new_map[index]+'></p>'
            end
        elsif campaign_map[index] == "REAL"
            if new_map[index] == ""
                form_html += '<p>'+campaign_ja[i]+':<input type="number" step="0.0001" name='+index+'></p>'
            else
                form_html += '<p>'+campaign_ja[i]+':<input type="number" step="0.0001" name='+index+' value='+new_map[index]+'></p>'
            end
        elsif campaign_map[index] == "DATETIME"
            date = new_map[index].gsub(' ', 'T')
            form_html += '<p>'+campaign_ja[i]+':<input type="datetime-local" name='+index+' value='+date+'></p>'
        elsif campaign_map[index] == "URL"
            form_html += '<p>'+campaign_ja[i]+':<input type="url" name='+index+' value='+new_map[index]+'></p>'
        else
            form_html += '<p>'+campaign_ja[i]+':<input type="datetime-local" name='+index+'></p>'
        end 
    end   
    form_html += '<p><input type="submit" value="反映する"><input type="reset" value="クリア"></p></form>'

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>表示マップ編集・登録ページ</title>
    </head>
    <body>
        <h2>#{h_t}</h2>
        #{form_html}
    </body>
    </html>
    
    EOF


rescue => ex

    print <<-EOF
    <html><body><pre>
    #{ex.message}
    </pre></body></html>
    EOF
end