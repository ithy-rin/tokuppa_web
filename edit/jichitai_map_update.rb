#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')

    #6
    campaign_map = {"j_m_id" => "INTEGER", "j_m_name" => "TEXT", "map_url" => "TEXT", "start" => "DATETIME", "end" => "DATETIME", "note" => "TEXT"}
    campaign_index = ["j_m_id", "j_m_name", "map_url", "start", "end", "note"]
    campaign_ja = ["id", "表示名", "マップ", "表示開始日", "表示終了日", "備考"]

    new_map = {}
    n_l = []
    for i in 0..campaign_index.length-1 do
        new_map[campaign_index[i]] = (cgi[campaign_index[i]] || '')
        n_l.push(cgi[campaign_index[i]] || '')
    end
    n_l[3] = n_l[3].gsub('T', ' ')
    n_l[4] = n_l[4].gsub('T', ' ')
    
    if edit == 'true'
        h_t = '編集'
        n_l[0] = n_l[0].to_i


        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("UPDATE jichitai_map SET j_m_name=?, map_url=?, start=?, end=?, note=? WHERE j_m_id=?;").execute(n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[0])
        my.close()

    else
        h_t = '登録'
        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.query("SELECT max(j_m_id) FROM jichitai_map;").each do |row|
            n_l[0] = row[0].to_i+1
        end
        my.prepare("INSERT INTO jichitai_map VALUES(?,?,?,?,?,?);").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5])
        my.close()

    end

    edit_url = "/app/edit/jichitai_map_form.rb?edit=false"
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
        <a href="/app/edit/jichitai_map_list.rb">リストへ戻る</a>
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