#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require "time"
require 'net/http'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'

require "csv"
require 'open-uri'

cgi = CGI.new
print cgi.header("text/plain; charset=utf-8")

begin
    now = Time.now
    print now

    url = 'https://docs.google.com/spreadsheets/d/1ZxJTiNvnbl2H0dGAe00bQP0721Y7TTZeEny6vI3R1TU/export?format=csv&gid=0'
    
    check = {}

    CSV.parse(open(url).string) do |n_l|
        if n_l[0] != nil
            if n_l[0] == 'kiyaku'
                check[n_l[0]] = n_l[1].to_i
            else
                check[n_l[0]] = n_l[1]
            end
        end
    
    end
        
    File.open("/home/c9357042/public_html/tokuppa.com/app/check.json", "w:UTF-8") do |n_f|
        JSON.dump(check, n_f) 
    end

    my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')
    url_top = 'https://docs.google.com/spreadsheets/d/1ZxJTiNvnbl2H0dGAe00bQP0721Y7TTZeEny6vI3R1TU/export?format=csv&gid=1656543105'
    
    q_index = ["t_id", "c_g", "t_name", "user", "img_url", "app_page", "d_URL", "start", "end", "note"]

    CSV.parse(open(url_top).string) do |n_l|
        if n_l[0] != nil
            my2.prepare("INSERT INTO top VALUES(?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE 
            t_id=VALUES(t_id), c_g=VALUES(c_g), t_name=VALUES(t_name), user=VALUES(user), img_url=VALUES(img_url),
            app_page=VALUES(app_page), d_URL=VALUES(d_URL), start=VALUES(start), end=VALUES(end), note=VALUES(note);            
            ").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9])           
        end
    end

    my2.close()

rescue => ex
    print ''
    print ex.message
end

