#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require 'time'
require './mysql/lib/mysql'
#require './mysql2/lib/mysql2'
#require './lib/mysql2'
#require './lib/mysql.rb'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    s_name = (cgi["s_name"] || '')
    issuer_id = (cgi["issuer_id"] || '')
 
    coupon_map = {"issuer_id" => "TEXT","c_id" => "INTEGER","s_name" => "TEXT","name" => "TEXT","top" => "TEXT","detail" => "TEXT","img_url" => "URL","d_url" => "URL","iosurl" => "URL","androidurl" => "URL","start" => "DATETIME","end" => "DATETIME","note" => "TEXT","cd_name" => "SELECT"}
    coupon_index = ["issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_url", "iosurl", "androidurl", "start", "end", "note", "cd_name"]
    coupon_ja = ["発行者", "id", "店舗名", "クーポン名", "表示", "詳細", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "備考", "発行名"]
    c_data = []
    st_data = []


    #my = Mysql2::Client.new(host: "mysql73.conoha.ne.jp", username: "hhkr8_ruby", password: 'app_2022ruby', database: 'hhkr8_store')
    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')


    if s_name!="" && issuer_id!=""
        sql_c_data = my.prepare("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id INNER JOIN coupon_data ON coupon_id.issuer_id=coupon_data.issuer_id WHERE (cd_name=? OR coupon_id.issuer_id=?) AND s_name=?;").execute(issuer_id, issuer_id, s_name)
    elsif s_name!=""
        sql_c_data = my.prepare("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id INNER JOIN coupon_data ON coupon_id.issuer_id=coupon_data.issuer_id WHERE s_name=?;").execute(s_name)
    elsif issuer_id!=""
        sql_c_data = my.prepare("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id INNER JOIN coupon_data ON coupon_id.issuer_id=coupon_data.issuer_id WHERE (cd_name=? OR coupon_id.issuer_id=?);").execute(issuer_id, issuer_id)
    else
        sql_c_data = my.query("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id INNER JOIN coupon_data ON coupon_id.issuer_id=coupon_data.issuer_id;")
    end

    sql_c_data.each do|row|
        c_data.push(row)
    end 

    st_map = {}
    st_data = 
    my.query("SELECT s_name, name FROM store_data").each do |col1, col2|
        st_map[col1] = col2
    end

    my.close()


    coupon_index_length = coupon_index.length-2

    html_table = '<table border="1" style="border-collapse: collapse"><thead><tr>'
    for i in 0..coupon_index_length do
        html_table += "<th>"+coupon_ja[i]+"</th>"
    end
    html_table += "<th>"+"編集"+"</th>"
    html_table += "<th>"+"追加"+"</th>"
    html_table += "<th>"+"削除"+"</th>"

    html_table += "</tr></thead>"
    table_body = "<tbody>"

    #結合したためc_dataの中身を1ずらす
    for x in 0..c_data.length-1 do
        table_body += "<tr>"
        edit_url = "/app/edit/coupon_form.rb?edit=true"
        delete_url = "/app/edit/coupon_delete.rb?delete=confirm"
        plus_url = "/app/edit/coupon_form_plus.rb?edit=plus"
        #cd_name表示
        table_body += "<th><a href=/app/edit/coupon_list.rb?issuer_id="+c_data[x][coupon_index.length+1].to_s+"&s_name="+s_name+">"+c_data[x][coupon_index.length+1].to_s+"</a></th>"
        edit_url += '&' + coupon_index[0] + '=' + c_data[x][0+1].to_s 
        #id
        table_body += "<th>"+c_data[x][1+1].to_s+"</th>"
        edit_url += '&' + coupon_index[1] + '=' + c_data[x][1+1].to_s 
        #検索表示
        table_body += "<th><a href=/app/edit/coupon_list.rb?issuer_id="+issuer_id+"&s_name="+c_data[x][2+1].to_s+">"+st_map[c_data[x][2+1].to_s]+"</a></th>"
        edit_url += '&' + coupon_index[2] + '=' + c_data[x][2+1].to_s 

        for i in 3..coupon_index_length do
            if i==10 || i==11
                table_body += "<th>"+c_data[x][i+1].to_s+"</th>"
                date = c_data[x][i+1].to_s.gsub(' ', 'T')
                edit_url += '&' + coupon_index[i] + '=' + date

            elsif c_data[x][i+1]!= nil
                table_body += "<th>"+c_data[x][i+1].to_s+"</th>"
                edit_url += '&' + coupon_index[i] + '=' + c_data[x][i+1].to_s 
            else
                table_body += "<th>"+" "+"</th>"
                edit_url += '&' + coupon_index[i] + '='
            end
        end
        if c_data[x][12+1]!= nil
            delete_url += '&note=' + c_data[x][12+1].to_s
        else
            delete_url += '&note='
        end
        if c_data[x][1+1]!= nil
            delete_url += '&c_id=' + c_data[x][1+1].to_s
            plus_url += '&c_id=' + c_data[x][1+1].to_s
        else
            delete_url += '&c_id='
        end
        if c_data[x][1]!= nil
            delete_url += '&issuer_id=' + c_data[x][1].to_s
            plus_url += '&issuer_id=' + c_data[x][1].to_s
        else
            delete_url += '&issuer_id='
        end
        table_body += "<th>"+"<a href="+edit_url+">編集</a>"+"</th>"
        table_body += "<th>"+"<a href="+plus_url+">追加</a>"+"</th>"
        table_body += "<th>"+"<a href="+delete_url+">削除</a>"+"</th>"

        table_body += "</tr>"
    end
    table_body += "</tbody></table>"

    search_html = '
    <form action="/app/edit/coupon_list.rb" method="get">
    <p>発行元:<input type="text" name="issuer_id" value="'+issuer_id+'"></p>
    <p>店名:<input type="text" name="s_name" value="'+s_name+'"></p>
    <p>
        <input type="submit" value="検索">
        <input type="reset" value="クリア">
    </p>
    </form>'
    if (issuer_id!='' || s_name!='')
        search_html += '<p>検索結果 ' + issuer_id + ' ' + s_name + '</p>'
    end

    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>クーポンリスト</title>
    </head>
    <body>
        <h2><a href="/app/edit/coupon_list.rb">クーポンリスト</a></h2>
        <h3><a href="/app/edit/campaign_list.rb">キャンペーンリストへ移動</a></h3>

        <a href="/app/edit/coupon_form.rb">新規登録</a>
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
