#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require "time"
require 'net/http'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/plain; charset=utf-8")

begin
    now = Time.now
    print now
    my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')

    news_list = []

    t_list = ['id', 'title', 'image', 'url', 'start', 'end', 'text']

    my2.query("SELECT * FROM app_news WHERE end>=NOW();").each do|row|
        news_hash = {}
        for i in 0..row.length-1 do
            news_hash[t_list[i]] = row[i]
        end

        File.open("/home/c9357042/public_html/tokuppa.com/app/news_page/"+row[0].to_s.rjust(10, '0')+".json", "w:UTF-8") do |n_f|
            JSON.dump(news_hash, n_f) 
        end
        news_list.push(news_hash)
    end 

    my2.close()



rescue => ex
    print ''
    print ex.message
end
