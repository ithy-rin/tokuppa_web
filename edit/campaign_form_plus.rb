#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require 'date'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    h_t = "店舗追加"
    edit = (cgi["edit"] || '')

    st_data = []
    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    my.query("SELECT s_name, name FROM store_data").each do |row|
        st_data.push(row)
    end

    my.close()


    campaign_map = {"s_name" => "TEXT","c_id" => "INTEGER","card_id" => "TEXT","c_name" => "TEXTAREAs","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","user" => "TEXT","no_user" => "TEXT","detail" => "TEXTAREA","img_url" => "TEXT","d_URL" => "TEXT","iosURL" => "TEXT","androidURL" => "TEXT","start" => "DATETIME", "end" => "DATETIME", "day" => "TEXT","same_cam" => "TEXT","give_date" => "DATETIME","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["s_name", "c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal"]
    campaign_ja = ["店舗名", "id", "カード名", "キャンペーン名", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "回数", "対象ユーザー", "対象外ユーザー", "詳細", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "対象日", "同一キャンペーン", "付与日", "エントリー", "備考", "カレンダー"]
    new_map = {}

    s_name = (cgi["s_name"] || '')
    c_id = (cgi["c_id"] || '')

    form_html = '<form action="/app/edit/campaign_update.rb" method="post">'
    form_html += '<input type="hidden" name="edit" value='+"plus"+'>'
    
    #発行者選択
    form_html += "<p>店舗 必須:<select name=s_name>"
    for i in 0..st_data.length-1 do
        if st_data[i][0] == s_name
            form_html += "<option value="+st_data[i][0]+" selected>"+st_data[i][1]+"</option>"
        else
            form_html += "<option value="+st_data[i][0]+">"+st_data[i][1]+"</option>"
        end
    end
    form_html += "</select></p>"

    form_html += '<input type="hidden" name='+"c_id"+' value='+c_id+'>'
 
    form_html += '<p><input type="submit" value="反映する"><input type="reset" value="クリア"></p></form>'

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>キャンペーン追加登録ページ</title>
    </head>
    <body>
        <h2>キャンペーン#{h_t}</h2>
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