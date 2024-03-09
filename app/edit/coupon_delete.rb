#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require 'time'
require './mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/html; charset=utf-8")

begin
    confirm = ''

    delete = (cgi["delete"] || '')
    c_id = (cgi["c_id"] || '')
    issuer_id = (cgi["issuer_id"] || '')
    if delete=='true' && c_id!='' && issuer_id!=''
        h_t = '削除完了'


        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("DELETE FROM coupon_id WHERE c_id=? AND issuer_id=?;").execute(c_id, issuer_id)
        my.close()

    elsif delete!='true' && c_id!='' && issuer_id!=''
        h_t = '削除しますか？'
        confirm = "<a href="+"/app/edit/coupon_delete.rb?delete=true"+'&c_id='+c_id+'&issuer_id='+issuer_id+">id="+c_id+" 発行者id="+issuer_id+" 削除</a>"
    else
        h_t = '削除失敗'
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
        <h2>#{h_t}</h2>
        #{confirm}
        <a href="/app/edit/coupon_list.rb">リストへ戻る</a>
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