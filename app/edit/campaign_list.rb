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
    s_name = (cgi["s_name"] || '')
    card_id = (cgi["card_id"] || '')
    hyouzi_limit = (cgi["hyouzi_limit"].to_i || 30)
    if hyouzi_limit == 0
        hyouzi_limit = 30
    end

    page_id = 0
 
    campaign_map = {"s_name" => "TEXT","c_id" => "INTEGER","card_id" => "TEXT","c_name" => "TEXTAREAs","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","user" => "TEXT","no_user" => "TEXT","detail" => "TEXTAREA","img_url" => "TEXT","d_URL" => "TEXT","iosURL" => "TEXT","androidURL" => "TEXT","start" => "DATETIME", "end" => "DATETIME", "day" => "TEXT","same_cam" => "TEXT","give_date" => "DATETIME","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["s_name", "c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal", "card_d_name"]
    campaign_ja = ["店舗名", "id", "カード名", "キャンペーン名", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "回数", "対象ユーザー", "対象外ユーザー", "詳細", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "対象日", "同一キャンペーン", "付与日", "エントリー", "備考", "カレンダー", "カード名"]
    c_data = []


    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    if s_name!="" && card_id!=""
        sql_c_data = my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id INNER JOIN card_data ON campaign.card_id=card_data.card_id INNER JOIN store_data ON campaign_id.s_name=store_data.s_name WHERE (card_data.card_d_name=? OR campaign.card_id=?) AND (campaign_id.s_name=? OR store_data.name=?) ORDER BY campaign_id.c_id DESC LIMIT ?;").execute(card_id, card_id, s_name, s_name, hyouzi_limit)
    elsif s_name!=""
        sql_c_data = my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id INNER JOIN card_data ON campaign.card_id=card_data.card_id INNER JOIN store_data ON campaign_id.s_name=store_data.s_name WHERE (campaign_id.s_name=? OR store_data.name=?) ORDER BY campaign_id.c_id DESC LIMIT ?;").execute(s_name, s_name, hyouzi_limit)
    elsif card_id!=""
        sql_c_data = my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id INNER JOIN card_data ON campaign.card_id=card_data.card_id INNER JOIN store_data ON campaign_id.s_name=store_data.s_name WHERE (card_data.card_d_name=? OR campaign.card_id=?) ORDER BY campaign_id.c_id DESC LIMIT ?;").execute(card_id, card_id, hyouzi_limit)
    else
        sql_c_data = my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id INNER JOIN card_data ON campaign.card_id=card_data.card_id INNER JOIN store_data ON campaign_id.s_name=store_data.s_name ORDER BY campaign_id.c_id DESC LIMIT ?;").execute(hyouzi_limit)
    end
    my.close()
    sql_c_data.each do|row|
        c_data.push(row)
    end 

    campaign_index_length = campaign_index.length-2

    html_table = '<table border="1" style="border-collapse: collapse"><thead><tr>'
    for i in 0..campaign_index_length do
        html_table += "<th>"+campaign_ja[i]+"</th>"
    end
    html_table += "<th>"+"編集"+"</th>"
    html_table += "<th>"+"追加"+"</th>"
    html_table += "<th>"+"削除"+"</th>"

    html_table += "</tr></thead>"
    table_body = "<tbody>"

    #結合したためc_dataの中身を1ずらす
    for x in 0..c_data.length-1 do
        table_body += "<tr>"
        edit_m = {}
        delete_url = "/app/edit/campaign_delete.rb?delete=confirm"
        plus_url = "/app/edit/campaign_form_plus.rb?edit=plus"


        #店舗名検索表示
        table_body += "<th><a href=/app/edit/campaign_list.rb?card_id="+card_id+"&s_name="+c_data[x][campaign_index.length+13+1+1].to_s+">"+c_data[x][campaign_index.length+13+1+1].to_s+"</a></th>"
        edit_m[campaign_index[0]] = c_data[x][0+1].to_s 
        plus_url += '&s_name=' + c_data[x][0+1].to_s
        delete_url += '&s_name=' + c_data[x][0+1].to_s

        #id
        table_body += "<th>"+c_data[x][1+1].to_s+"</th>"
        edit_m[campaign_index[1]] = c_data[x][1+1].to_s 
        #card_d_name表示
        table_body += "<th><a href=/app/edit/campaign_list.rb?card_id="+c_data[x][campaign_index.length+1].to_s+"&s_name="+s_name+">"+c_data[x][campaign_index.length+1].to_s+"</a></th>"
        edit_m[campaign_index[2]] = c_data[x][2+1].to_s 




        for i in 3..campaign_index_length do
            if i==19 || i==20
                table_body += "<th>"+c_data[x][i+1].to_s+"</th>"
                date = c_data[x][i+1].to_s.gsub(' ', 'T')
                edit_m[campaign_index[i]] = date
            elsif i>=16 && i<=19 && c_data[x][i+1] != ""
                table_body += "<th><a href="+c_data[x][i+1].to_s+">詳細</a></th>"
                edit_m[campaign_index[i]] = c_data[x][i+1].to_s 

            elsif c_data[x][i+1]!= nil
                table_body += "<th>"+c_data[x][i+1].to_s+"</th>"
                edit_m[campaign_index[i]] = c_data[x][i+1].to_s 

            else
                table_body += "<th>"+" "+"</th>"
                edit_m[campaign_index[i]] = ""
            end
        end
        if c_data[x][1+1]!= nil
            delete_url += '&c_id=' + c_data[x][1+1].to_s
            plus_url += '&c_id=' + c_data[x][1+1].to_s
        else
            delete_url += '&c_id='
        end

        table_body += "<th>"+"<a href=/app/edit/campaign_form.rb?edit=true&"+URI.encode_www_form(edit_m)+">編集</a>"+"</th>"
        table_body += "<th>"+"<a href="+plus_url+">追加</a>"+"</th>"
        table_body += "<th>"+"<a href="+delete_url+">削除</a>"+"</th>"

        table_body += "</tr>"
    end
    table_body += "</tbody></table>"

    search_html = '
    <form action="/app/edit/campaign_list.rb" method="get">
    <p>カード名:<input type="text" name="card_id" value="'+card_id+'"></p>
    <p>店名:<input type="text" name="s_name" value="'+s_name+'"></p>
    <p>
        <input type="submit" value="検索">
        <input type="reset" value="クリア">
    </p>
    </form>'
    if (card_id!='' || s_name!='')
        search_html += '<p>検索結果 ' + card_id + ' ' + s_name + ' 表示件数 ' + hyouzi_limit.to_s + '</p>'
    end

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>キャンペーンリスト</title>
    </head>
    <body>
        <h2><a href="/app/edit/campaign_list.rb">キャンペーンリスト</a></h2>
        <h3><a href="/app/edit/coupon_list.rb">クーポンリストへ移動</a></h3>
        <h3><a href="/app/edit/jichitai_list.rb">自治体キャンペーンリストへ移動</a></h3>

        <a href="/app/edit/campaign_form.rb">キャンペーン新規登録</a>
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
