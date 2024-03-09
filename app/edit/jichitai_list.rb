#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require 'time'
#require './mysql/lib/mysql'
require './lib/mysql.rb'

require 'uri'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    s_name = (cgi["s_name"] || '')
    card_id = (cgi["card_id"] || '')
 
    campaign_map = {"j_id" => "INTEGER","card_id" => "TEXT","j_name" => "TEXT","j_num" => "INTEGER","pref" => "TEXT","city" => "TEXT","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","detail" => "TEXT","img_url" => "TEXT","d_URL" => "TEXT","start" => "TEXT","end" => "TEXT","give_date" => "TEXT","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["j_id", "card_id", "j_name", "j_num", "pref", "city", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "detail", "img_url", "d_URL", "start", "end", "give_date", "entry", "note", "cal"]
    campaign_ja = ["id", "カードid", "キャンペーン名", "自治体コード", "都道府県", "市区町村", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "上限回数", "詳細", "画像URL", "詳細URL", "開始日", "終了日", "付与日", "エントリー", "備考", "カレンダー"]
    c_data = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    if s_name!="" && card_id!=""
        sql_c_data = my.prepare("SELECT * FROM jichitai INNER JOIN card_data ON jichitai.card_id=card_data.card_id WHERE (card_data.card_d_name=? OR jichitai.card_id=?) AND (jichitai.pref=? OR jichitai.city=?) AND jichitai.note not like '_DEL' ORDER BY end DESC;").execute(card_id, card_id, s_name, s_name)
    elsif s_name!=""
        sql_c_data = my.prepare("SELECT * FROM jichitai INNER JOIN card_data ON jichitai.card_id=card_data.card_id WHERE (jichitai.pref=? OR jichitai.city=?) AND jichitai.note not like '_DEL' ORDER BY end DESC;").execute(s_name, s_name)
    elsif card_id!=""
        sql_c_data = my.prepare("SELECT * FROM jichitai INNER JOIN card_data ON jichitai.card_id=card_data.card_id WHERE (card_data.card_d_name=? OR jichitai.card_id=?) AND jichitai.note not like '_DEL' ORDER BY end DESC;").execute(card_id, card_id)
    else
        sql_c_data = my.query("SELECT * FROM jichitai INNER JOIN card_data ON jichitai.card_id=card_data.card_id WHERE jichitai.note not like '_DEL' ORDER BY end DESC;")
    end
    my.close()
    sql_c_data.each do|row|
        c_data.push(row)
    end 
    
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
        delete_url = "/app/edit/jichitai_delete.rb?delete=confirm"
        
        table_body += "<th>"+c_data[x][0].to_s+"</th>"
        edit_m[campaign_index[0]] = c_data[x][0].to_s 
        #card_d_name表示
        table_body += "<th><a href=/app/edit/jichitai_list.rb?card_id="+c_data[x][campaign_index.length+1].to_s+"&s_name="+s_name+">"+c_data[x][campaign_index.length+1].to_s+"</a></th>"
        edit_m[campaign_index[1]] = c_data[x][1].to_s 
        #検索表示
        #table_body += "<th><a href=/app/edit/jichitai_list.rb?card_id="+card_id+"&s_name="+c_data[x][campaign_index.length+13+1].to_s+">"+c_data[x][campaign_index.length+13+1].to_s+"</a></th>"

        for i in 2..campaign_index_length do
            if i==18 || i==19 || i==20
                table_body += "<th>"+c_data[x][i].to_s+"</th>"
                date = c_data[x][i].to_s.gsub(' ', 'T')
                edit_m[campaign_index[i]] = date
            elsif i>=16 && i<=17 && c_data[x][i] != ""
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
        if c_data[x][23]!= nil
            delete_url += '&note=' + c_data[x][23].to_s
        else
            delete_url += '&note='
        end
        if c_data[x][0]!= nil
            delete_url += '&c_id=' + c_data[x][0].to_s
        else
            delete_url += '&c_id='
        end

        table_body += "<th>"+"<a href=/app/edit/jichitai_form.rb?edit=true&"+URI.encode_www_form(edit_m)+">編集</a>"+"</th>"
        table_body += "<th>"+"<a href="+delete_url+">削除</a>"+"</th>"

        table_body += "</tr>"
    end
    table_body += "</tbody></table>"

    search_html = '
    <form action="/app/edit/jichitai_list.rb" method="get">
    <p>カード名:<input type="text" name="card_id" value="'+card_id+'"></p>
    <p>都道府県・市区町村名:<input type="text" name="s_name" value="'+s_name+'"></p>
    <p>
        <input type="submit" value="検索">
        <input type="reset" value="クリア">
    </p>
    </form>'
    if (card_id!='' || s_name!='')
        search_html += '<p>検索結果 ' + card_id + ' ' + s_name + '</p>'
    end

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>自治体キャンペーンリスト</title>
    </head>
    <body>
        <h2><a href="/app/edit/jichitai_list.rb">自治体キャンペーンリスト</a></h2>
        <h3><a href="/app/edit/coupon_list.rb">クーポンリストへ移動</a></h3>
        <h3><a href="/app/edit/campaign_list.rb">キャンペーンリストへ移動</a></h3>
        <a href="/app/edit/jichitai_map_list.rb">表示マップリスト</a>
        <br>
        <a href="/app/edit/jichitai_form.rb">自治体キャンペーン新規登録</a>

        #{search_html}
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
