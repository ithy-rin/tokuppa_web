#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')

    #24
    campaign_map = {"j_id" => "INTEGER","card_id" => "TEXT","j_name" => "TEXT","j_num" => "INTEGER","pref" => "TEXT","city" => "TEXT","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","detail" => "TEXT","img_url" => "TEXT","d_URL" => "TEXT","start" => "DATETIME","end" => "DATETIME","give_date" => "DATETIME","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["j_id", "card_id", "j_name", "j_num", "pref", "city", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "detail", "img_url", "d_URL", "start", "end", "give_date", "entry", "note", "cal"]
    campaign_ja = ["id", "カードid", "キャンペーン名", "自治体コード", "都道府県", "市区町村", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "上限回数", "詳細", "画像URL", "詳細URL", "開始日", "終了日", "付与日", "エントリー", "備考", "カレンダー", "カード名"]

    new_map = {}
    n_l = []
    for i in 0..campaign_index.length-1 do
        new_map[campaign_index[i]] = (cgi[campaign_index[i]] || '')
        n_l.push(cgi[campaign_index[i]] || '')
    end
    n_l[18] = n_l[18].gsub('T', ' ')
    n_l[19] = n_l[19].gsub('T', ' ')
    n_l[20] = n_l[20].gsub('T', ' ')
    if n_l[18]==''
        n_l[18] = '0000-01-01 00:00:00'
    end
    if n_l[19]==''
        n_l[19] = '0000-01-01 00:00:00'
    end
    if n_l[20]==''
        n_l[20] = '0000-01-01 00:00:00'
    end

    n_l[6] = (cgi['way_0'] || '')+'_'+(cgi['way_1'] || '')+'_'+(cgi['way_2'] || '')
    
    if edit == 'true'
        h_t = '編集'
        n_l[0] = n_l[0].to_i

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("UPDATE jichitai SET card_id=?, j_name=?, j_num=?, pref=?, city=?, way=?, w1=?, w2=?, w3=?, rate=?, min=?, max_once=?, max_term=?, max_times=?, detail=?, img_url=?, d_URL=?, start=?, end=?, give_date=?, entry=?, note=?, cal=? WHERE j_id=?;").execute(n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23], n_l[0])
        my.close()
    else
        h_t = '登録'
        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.query("SELECT max(j_id) FROM jichitai;").each do |row|
            n_l[0] = row[0].to_i+1
        end
        my.prepare("INSERT INTO jichitai VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23])
        my.close()
    end

    edit_url = "/app/edit/jichitai_form.rb?edit=false"
    for i in 0..campaign_index.length-1 do
        index = campaign_index[i]

        if new_map[index]!= nil
            edit_url += '&' + campaign_index[i] + '=' + new_map[index].to_s 
        else
            edit_url += '&' + campaign_index[i] + '='
        end
    end

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>編集・登録ページ</title>
    </head>
    <body>
        <h2>#{h_t}完了</h2>
        <a href="/app/edit/jichitai_list.rb">リストへ戻る</a>
        <a href=#{edit_url}>続けて登録する</a>
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