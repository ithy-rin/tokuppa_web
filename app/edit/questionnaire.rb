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

    q = {}
    q_index = ["q_id", "q_name", "user", "q_count", "detail", "d_URL", "start", "end", "note"]
    sql_c_data = my2.query("SELECT * FROM questionnaire WHERE start<=NOW() AND end>=NOW();")
    sql_c_data.each do|row|
        laa = {}
        for x in 1..q_index.length-1 do
            if row[x] == nil
                laa[q_index[x]] = ''
            else
                laa[q_index[x]] = row[x]
            end
        end
        q[row[0].to_s] = laa
    end 
    my2.close()

    r_json = {}
    r_json['time'] = Time.now
    
    r_json['data'] = q

        
    File.open("/home/c9357042/public_html/tokuppa.com/app/questionnaire.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end

rescue => ex
    print ''
    print ex.message
end

