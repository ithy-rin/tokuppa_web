#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require 'net/http'
require 'time'
require './mysql/lib/mysql'
require 'uri'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
 
    campaign_map = {"j_m_id" => "INTEGER", "j_m_name" => "TEXT", "map_url" => "TEXT", "start" => "DATETIME", "end" => "DATETIME", "note" => "TEXT"}
    campaign_index = ["j_m_id", "j_m_name", "map_url", "start", "end", "note"]
    campaign_ja = ["id", "表示名", "マップ", "表示開始日", "表示終了日", "備考"]
    c_data = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM jichitai_map WHERE note not like '_DEL' ORDER BY end DESC;").each do |row|
        c_data.push(row)
    end
    my.close()

    campaign_index_length = campaign_index.length-1

    html_table = '<table border="1" style="border-collapse: collapse"><thead><tr>'
    for i in 0..campaign_index_length do
        html_table += "<th>"+campaign_ja[i]+"</th>"
    end
    html_table += "<th>"+"編集"+"</th>"
    html_table += "<th>"+"削除"+"</th>"

    html_table += "</tr></thead>"
    table_body = "<tbody>"
    for x in 0..c_data.length-1 do
        table_body += "<tr>"
        edit_m = {}
        delete_url = "/app/edit/jichitai_map_delete.rb?delete=confirm"
        
        table_body += "<th>"+c_data[x][0].to_s+"</th>"
        edit_m[campaign_index[0]] = c_data[x][0].to_s 

        for i in 1..campaign_index_length do
            if i==3 || i==4
                table_body += "<th>"+c_data[x][i].to_s+"</th>"
                date = c_data[x][i].to_s.gsub(' ', 'T')
                edit_m[campaign_index[i]] = date
            elsif i==2 && c_data[x][i] != ""
                table_body += "<th><a href="+c_data[x][i].to_s+">詳細</a></th>"
                edit_m[campaign_index[i]] = c_data[x][i].to_s 
            elsif c_data[x][i]!= nil
                table_body += "<th>"+c_data[x][i].to_s+"</th>"
                edit_m[campaign_index[i]] = c_data[x][i].to_s 

            else
                table_body += "<th>"+" "+"</th>"
                edit_m[campaign_index[i]] = ""
            end
        end
        if c_data[x][5]!= nil
            delete_url += '&note=' + c_data[x][5].to_s
        else
            delete_url += '&note='
        end
        if c_data[x][0]!= nil
            delete_url += '&c_id=' + c_data[x][0].to_s
        else
            delete_url += '&c_id='
        end

        table_body += "<th>"+"<a href=/app/edit/jichitai_map_form.rb?edit=true&"+URI.encode_www_form(edit_m)+">編集</a>"+"</th>"
        table_body += "<th>"+"<a href="+delete_url+">削除</a>"+"</th>"

        table_body += "</tr>"
    end
    table_body += "</tbody></table>"

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>表示マップリスト</title>
    </head>
    <body>
        <h2><a href="/app/edit/jichitai_map_list.rb">表示マップリスト</a></h2>
        <h3><a href="/app/edit/jichitai_list.rb">自治体キャンペーンリストへ移動</a></h3>

        <a href="/app/edit/jichitai_map_form.rb">表示マップ新規登録</a>
        #{html_table}
        #{table_body}

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
