#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require 'date'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    edit = (cgi["edit"] || '')
    if edit == 'true'
        h_t = '編集'
    else
        h_t = '登録'
    end

    cd_data = []
    st_data = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    my.query("SELECT issuer_id, cd_name FROM coupon_data;").each do |row|
        cd_data.push(row)
    end
    my.query("SELECT s_name, name FROM store_data;").each do |row|
        st_data.push(row)
    end  
    my.close()


    coupon_map = {"issuer_id" => "TEXT","c_id" => "INTEGER","s_name" => "TEXT","name" => "TEXTAREAs","top" => "TEXT","detail" => "TEXTAREA","img_url" => "URL","d_url" => "URL","iosurl" => "URL","androidurl" => "URL","start" => "DATETIME","end" => "DATETIME","note" => "TEXT"}
    coupon_index = ["issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_url", "iosurl", "androidurl", "start", "end", "note"]
    coupon_ja = ["発行者 必須", "id", "店舗名 必須", "クーポン名 必須", "表示", "詳細 現在表示はされません", "画像URL", "詳細URL", "iosURL", "androidURL", "開始日", "終了日", "備考"]
    new_map = {}
    for i in 0..coupon_index.length-1 do
        new_map[coupon_index[i]] = (cgi[coupon_index[i]] || '')
    end
    form_html = '<form action="/app/edit/coupon_update.rb" method="post">'
    form_html += '<input type="hidden" name="edit" value='+edit+'>'
    
    #発行者選択
    form_html += "<p>発行者 必須:<select name=issuer_id>"
    for i in 0..cd_data.length-1 do
        if cd_data[i][0] == new_map["issuer_id"]
            form_html += "<option value="+cd_data[i][0]+" selected>"+cd_data[i][1]+"</option>"
        else
            form_html += "<option value="+cd_data[i][0]+">"+cd_data[i][1]+"</option>"
        end
    end
    form_html += "</select></p>"
    #お店選択
    form_html += "<p>店名 必須:<select name=s_name>"
    for i in 0..st_data.length-1 do
        if st_data[i][0] == new_map["s_name"]
            form_html += "<option value="+st_data[i][0]+" selected>"+st_data[i][1]+"</option>"
        else
            form_html += "<option value="+st_data[i][0]+">"+st_data[i][1]+"</option>"
        end
    end
    form_html += "</select></p>"
    form_html += '<input type="hidden" name='+"c_id"+' value='+new_map["c_id"]+'>'
    form_html += '<input type="hidden" name='+"before_issuer_id"+' value='+new_map["issuer_id"]+'>'

    for i in 3..coupon_index.length-1 do
        index = coupon_index[i]
        if index == 'c_id'
            form_html += '<input type="hidden" name='+index+' value='+new_map[index]+'>'
        elsif coupon_map[index] == "TEXT"
            form_html += '<p>'+coupon_ja[i]+':<input type="text" name='+index+' value='+new_map[index]+'></p>'
        elsif coupon_map[index] == "INTEGER"
            form_html += '<p>'+coupon_ja[i]+':<input type="number" name='+index+' value='+new_map[index].to_i+'></p>'
        elsif coupon_map[index] == "REAL"
            form_html += '<p>'+coupon_ja[i]+':<input type="number" step="0.0001" name='+index+' value='+new_map[index].tof+'></p>'
        elsif coupon_map[index] == "TEXTAREA"
            form_html += '<p>'+coupon_ja[i]+':<textarea rows="2" cols="40" name='+index+'>'+new_map[index]+'</textarea></p>'
        elsif coupon_map[index] == "TEXTAREAs"
            form_html += '<p>'+coupon_ja[i]+':<textarea rows="1" cols="40" name='+index+'>'+new_map[index]+'</textarea></p>'
        
        elsif coupon_map[index] == "DATETIME"
            date = new_map[index].gsub(' ', 'T')
            if date == '' && index == 'start'
                date = Date.today.to_s + 'T00:00:00'
            elsif date == '' && index == 'end'
                date = Date.today.to_s + 'T23:59:00'
            end
            form_html += '<p>'+coupon_ja[i]+':<input type="datetime-local" name='+index+' value='+date+' required></p>'
        elsif coupon_map[index] == "URL"
            form_html += '<p>'+coupon_ja[i]+':<input type="url" name='+index+' value='+new_map[index]+'></p>'
        else
            form_html += '<p>'+coupon_ja[i]+':<input type="datetime-local" name='+index+'></p>'
        end 
    end   
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