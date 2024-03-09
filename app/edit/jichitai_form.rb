#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
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
    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    my.query("SELECT card_id, card_d_name FROM card_data;").each do |row|
        cd_data.push(row)
    end

 
    campaign_map = {"j_id" => "INTEGER","card_id" => "TEXT","j_name" => "TEXT","j_num" => "INTEGER","pref" => "TEXT","city" => "TEXT","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","detail" => "TEXT","img_url" => "TEXT","d_URL" => "TEXT","start" => "DATETIME","end" => "DATETIME","give_date" => "DATETIME","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["j_id", "card_id", "j_name", "j_num", "pref", "city", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "detail", "img_url", "d_URL", "start", "end", "give_date", "entry", "note", "cal"]
    campaign_ja = ["id", "カードid", "キャンペーン名", "自治体コード", "都道府県", "市区町村", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "上限回数", "詳細", "画像URL", "詳細URL", "開始日", "終了日", "付与日", "エントリー", "備考", "カレンダー", "カード名"]

    way_l = [["per", "mai", "yen", "loto", "else_a"], ["back", "biki", "else_b"], ["plus", "only", "else_c"]]
    way_ja = {"per" => "?% 割合を小数表記で①に入力", "mai" => "?円毎に?p ①, ②", "yen" => "?円引き、還元 ①", "loto" => "抽選 期待値があれば①に入力", "back" => "後から還元", "biki" => "即時割引", "plus" => "他のにプラスして還元", "only" => "0%からプラスして還元", "else_a" => "割引その他", "else_b" => "還元方法その他", "else_c" => "計算方法その他"}
    way_p = ["割引方法", "還元方法", "計算方法"]
    
    new_map = {}
    for i in 0..campaign_index.length-1 do
        new_map[campaign_index[i]] = (cgi[campaign_index[i]] || '')
    end
    form_html = '<form action="/app/edit/jichitai_update.rb" method="post">'
    form_html += '<input type="hidden" name="edit" value='+edit+'>'
    
    #発行者選択
    form_html += "<p>カード名 必須:<select name=card_id>"
    for i in 0..cd_data.length-1 do
        if cd_data[i][0] == new_map["card_id"]
            form_html += "<option value="+cd_data[i][0]+" selected>"+cd_data[i][1]+"</option>"
        else
            form_html += "<option value="+cd_data[i][0]+">"+cd_data[i][1]+"</option>"
        end
    end
    form_html += "</select></p>"

    for i in 0..campaign_index.length-1 do
        index = campaign_index[i]


        if index == 'j_id'
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
                form_html += '<p>'+campaign_ja[i]+':<input type="number" name='+index+' value=0></p>'
            else
                form_html += '<p>'+campaign_ja[i]+':<input type="number" name='+index+' value='+new_map[index]+'></p>'
            end
        elsif campaign_map[index] == "REAL"
            if new_map[index] == ""
                form_html += '<p>'+campaign_ja[i]+':<input type="number" step="0.0001" name='+index+' value=0></p>'
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
        <title>キャンペーン編集・登録ページ</title>
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