#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require 'date'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    h_t = "発行者追加"
    edit = (cgi["edit"] || '')

    cd_data = []
    st_data = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    my.query("SELECT issuer_id, cd_name FROM coupon_data;").each do |row|
        cd_data.push(row)
    end
    my.close()


    coupon_map = {"issuer_id" => "TEXT","c_id" => "INTEGER","s_name" => "TEXT","name" => "TEXT","top" => "TEXT","detail" => "TEXT","img_url" => "URL","d_url" => "URL","iosurl" => "URL","androidurl" => "URL","start" => "DATETIME","end" => "DATETIME","note" => "TEXT"}
    coupon_index = ["issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_url", "iosurl", "androidurl", "start", "end", "note"]
    coupon_ja = ["発行者 必須", "id", "店舗名 必須", "クーポン名 必須", "表示", "詳細 現在表示はされません", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "備考"]
    new_map = {}

    issuer_id = (cgi["issuer_id"] || '')
    c_id = (cgi["c_id"] || '')

    form_html = '<form action="/app/edit/coupon_update.rb" method="post">'
    form_html += '<input type="hidden" name="edit" value='+"plus"+'>'
    
    #発行者選択
    form_html += "<p>発行者 必須:<select name=issuer_id>"
    for i in 0..cd_data.length-1 do
        if cd_data[i][0] == issuer_id
            form_html += "<option value="+cd_data[i][0]+" selected>"+cd_data[i][1]+"</option>"
        else
            form_html += "<option value="+cd_data[i][0]+">"+cd_data[i][1]+"</option>"
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
        <title>クーポン編集・登録ページ</title>
    </head>
    <body>
        <h2>クーポン#{h_t}</h2>
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