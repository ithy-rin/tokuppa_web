#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require 'net/http'
require 'time'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'

require "csv"
require 'open-uri'


cgi = CGI.new
print cgi.header("text/json; charset=utf-8")
begin
    now = Time.now

    campaign = []
    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    url = 'https://docs.google.com/spreadsheets/u/2/d/1lYF-Vm-ZqA3_6z5bc9VcoPn6Du8bBis5nHIQ0bojnFU/export?format=csv&gid=510842643'
    x = ''
    
    open(url) do |file|
        CSV.foreach(file, encoding: 'utf-8') do |n_l|            
            x = n_l

            my.prepare("INSERT INTO campaign VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE 
             card_id=VALUES(card_id), c_name=VALUES(c_name), way=VALUES(way), w1=VALUES(w1), w2=VALUES(w2), w3=VALUES(w3), rate=VALUES(rate), min=VALUES(min), max_once=VALUES(max_once), max_term=VALUES(max_term), max_times=VALUES(max_times), user=VALUES(user), no_user=VALUES(no_user), detail=VALUES(detail), img_url=VALUES(img_url), d_URL=VALUES(d_URL), iosURL=VALUES(iosURL), androidURL=VALUES(androidURL), start=VALUES(start), end=VALUES(end), day=VALUES(day), w_day=VALUES(w_day), give_date=VALUES(give_date), entry=VALUES(entry), note=VALUES(note), cal=VALUES(cal);
            ").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23], n_l[24], n_l[25], n_l[26])
                        
        end
    end
    url_id = 'https://docs.google.com/spreadsheets/u/2/d/1lYF-Vm-ZqA3_6z5bc9VcoPn6Du8bBis5nHIQ0bojnFU/export?format=csv&gid=0'

    open(url_id) do |file|
        CSV.foreach(file, encoding: 'utf-8') do |n_l|            

            my.prepare("INSERT INTO campaign_id VALUES(?,?) ON DUPLICATE KEY UPDATE 
            c_id=VALUES(c_id), s_name=VALUES(s_name);
            ").execute(n_l[0], n_l[1])
                        
        end
    end


    my.close()

    
rescue => ex
    print ex.message
    print x
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    r_json['map'] = ['error']

    print r_json.to_json

end
