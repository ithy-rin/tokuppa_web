#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')
    before = (cgi["before_issuer_id"] || '')

    coupon_map = {"issuer_id" => "TEXT","c_id" => "INTEGER","s_name" => "TEXT","name" => "TEXT","top" => "TEXT","detail" => "TEXT","img_url" => "URL","d_url" => "URL","iosurl" => "URL","androidurl" => "URL","start" => "DATETIME","end" => "DATETIME","note" => "TEXT"}
    coupon_index = ["issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_url", "iosurl", "androidurl", "start", "end", "note"]
    coupon_ja = ["発行者", "id", "店舗名", "クーポン名", "表示", "詳細", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "備考"]
    new_map = {}
    n_l = []

    for i in 0..coupon_index.length-1 do
        new_map[coupon_index[i]] = (cgi[coupon_index[i]] || '')
        n_l.push(cgi[coupon_index[i]] || '')
    end
    n_l[10] = n_l[10].gsub('T', ' ')
    if n_l[10]==''
        n_l[10] = '0000-01-01 00:00:00'
    end
    n_l[11] = n_l[11].gsub('T', ' ')
    if n_l[11]==''
        n_l[11] = '0000-01-01 00:00:00'
    end

    if edit == 'true'
        h_t = '編集'
        n_l[1] = n_l[1].to_i

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("UPDATE coupon SET s_name=?, name=?, top=?, detail=?, img_url=?, d_URL=?, iosURL=?, androidURL=?, start=?, end=?, note=? WHERE c_id=?;").execute(n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[1])
        my.prepare("UPDATE coupon_id SET issuer_id=? WHERE c_id=? AND issuer_id=?;").execute(n_l[0], n_l[1], before)

        my.close()

    elsif edit == 'plus'
        h_t = '発行者追加'
        n_l[1] = n_l[1].to_i

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("INSERT INTO coupon_id VALUES(?,?);").execute(n_l[1], n_l[0])

        my.close()

    else
        h_t = '登録'

        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.query("SELECT max(c_id) FROM coupon;").each do |row|
            n_l[1] = row[0].to_i+1
        end

        my.prepare("INSERT INTO coupon VALUES(?,?,?,?,?,?,?,?,?,?,?,?);").execute(n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12])
        my.prepare("INSERT INTO coupon_id VALUES(?,?);").execute(n_l[1], n_l[0])

        my.close()

    end

    edit_url = "/app/edit/coupon_form.rb?edit=false&"+URI.encode_www_form(new_map)


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
        <a href="/app/edit/coupon_list.rb">リストへ戻る</a>
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