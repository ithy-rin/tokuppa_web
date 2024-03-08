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
    note = (cgi["note"] || '')

    if delete=='true' && c_id!=''
        h_t = '削除完了'
        note = note + '_DEL'
        my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
        my.prepare("UPDATE jichitai_map SET note=? WHERE j_m_id=?;").execute(note, c_id)
        my.close()
    elsif delete!='true' && c_id!=''
        h_t = '削除しますか？'
        confirm = "<a href="+"/app/edit/jichitai_map_delete.rb?delete=true"+'&note='+note+'&c_id='+c_id+">id="+c_id+" 削除</a>"
    else
        h_t = '削除失敗'
    end
    print <<-EOF
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>削除ページ</title>
    </head>
    <body>
        <h2>#{h_t}</h2>
        #{confirm}
        <a href="/app/edit/jichitai_map_list.rb">リストへ戻る</a>
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