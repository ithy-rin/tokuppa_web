#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
require 'uri'

cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')
    before = (cgi["before_s_name"] || '')

    
    campaign_map = {"s_name" => "TEXT","c_id" => "INTEGER","card_id" => "TEXT","c_name" => "TEXTAREAs","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","user" => "TEXT","no_user" => "TEXT","detail" => "TEXTAREA","img_url" => "TEXT","d_URL" => "TEXT","iosURL" => "TEXT","androidURL" => "TEXT","start" => "DATETIME", "end" => "DATETIME", "day" => "TEXT","same_cam" => "TEXT","give_date" => "DATETIME","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["s_name", "c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal"]
    campaign_ja = ["店舗名", "id", "カード名", "キャンペーン名", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "回数", "対象ユーザー", "対象外ユーザー", "詳細", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "対象日", "同一キャンペーン", "付与日", "エントリー", "備考", "カレンダー"]

    new_map = {}
    n_l = []
    for i in 0..campaign_index.length-1 do
        new_map[campaign_index[i]] = (cgi[campaign_index[i]] || '')
        if campaign_map[campaign_index[i]] == "INTEGER" || campaign_map[campaign_index[i]] == "REAL"
            n_l.push(cgi[campaign_index[i]] || 0)

        else
            n_l.push(cgi[campaign_index[i]] || '')
        end
    end
    if n_l[20]==''
        n_l[20] = '0000-01-01 00:00:00'
    end
    n_l[20] = n_l[20].gsub('T', ' ')
    if n_l[21]==''
        n_l[21] = '0000-01-01 00:00:00'
    end
    n_l[21] = n_l[21].gsub('T', ' ')
    if n_l[24]==''
        n_l[24] = '0000-01-01 00:00:00'
    end
    n_l[24] = n_l[24].gsub('T', ' ')



    n_l[4] = (cgi['way_0'] || '')+'_'+(cgi['way_1'] || '')+'_'+(cgi['way_2'] || '')
    
    if edit == 'true'
        h_t = '編集'
        n_l[1] = n_l[1].to_i

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("UPDATE campaign SET card_id=?, c_name=?, way=?, w1=?, w2=?, w3=?, rate=?, min=?, max_once=?, max_term=?, max_times=?, user=?, no_user=?, detail=?, img_url=?, d_URL=?, iosURL=?, androidURL=?, start=?, end=?, day=?, w_day=?, give_date=?, entry=?, note=?, cal=? WHERE c_id=?;").execute(n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23], n_l[24], n_l[25], n_l[26], n_l[27], n_l[1])
        my.prepare("UPDATE campaign_id SET s_name=? WHERE c_id=? AND s_name=?;").execute(n_l[0], n_l[1], before)
        my.close()
    elsif edit == 'plus'
        h_t = '店舗追加'
        n_l[1] = n_l[1].to_i

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("INSERT INTO campaign_id VALUES(?,?);").execute(n_l[1], n_l[0])

        my.close()
    else
        h_t = '登録'


        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.query("SELECT max(c_id) FROM campaign;").each do |row|
            n_l[1] = row[0].to_i+1
        end
        my.prepare("INSERT INTO campaign VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);").execute(n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23], n_l[24], n_l[25], n_l[26], n_l[27])
        my.prepare("INSERT INTO campaign_id VALUES(?,?);").execute(n_l[1], n_l[0])
        my.close()

    end

    edit_url = "/app/edit/campaign_form.rb?edit=false&"+URI.encode_www_form(new_map)


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
        <a href="/app/edit/campaign_list.rb">リストへ戻る</a>
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