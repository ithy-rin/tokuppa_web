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

    url = 'https://docs.google.com/spreadsheets/u/2/d/1t1YMHJuSS6TCCtpegD_GHTh9aO2YmxrRtskqwiq2bFI/export?format=csv&gid=510842643'

    print 'a'
    open(url) do |file|
        CSV.foreach(file, encoding: 'utf-8') do |n_l|            
            my.prepare("INSERT INTO all_campaign VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE 
            card_id=VALUES(card_id), c_name=VALUES(c_name), way=VALUES(way), w1=VALUES(w1), w2=VALUES(w2), w3=VALUES(w3), rate=VALUES(rate), min=VALUES(min), max_once=VALUES(max_once), max_term=VALUES(max_term), max_times=VALUES(max_times), user=VALUES(user), no_user=VALUES(no_user), detail=VALUES(detail), img_url=VALUES(img_url), d_URL=VALUES(d_URL), iosURL=VALUES(iosURL), androidURL=VALUES(androidURL), start=VALUES(start), end=VALUES(end), day=VALUES(day), w_day=VALUES(w_day), give_date=VALUES(give_date), entry=VALUES(entry), note=VALUES(note), cal=VALUES(cal), os_name=VALUES(os_name);
            ").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23], n_l[24], n_l[25], n_l[26], n_l[27])
                        
        end
    end
    print 'b'
    #jichitai
    #(.+?), 
    #$1=VALUES($1), 
    url_id = 'https://docs.google.com/spreadsheets/u/2/d/1skUBYym-CtXTY4LWFqCcg49XuPfJtLFuD1KEcSzs91I/export?format=csv&gid=0'
    open(url_id) do |file|
        CSV.foreach(file, encoding: 'utf-8') do |n_l|            
            print n_l[0]

            my.prepare("INSERT INTO jichitai VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE 
            card_id=VALUES(card_id), j_name=VALUES(j_name), j_num=VALUES(j_num), pref=VALUES(pref), city=VALUES(city), way=VALUES(way), w1=VALUES(w1), w2=VALUES(w2), w3=VALUES(w3), rate=VALUES(rate), min=VALUES(min), max_once=VALUES(max_once), max_term=VALUES(max_term), max_times=VALUES(max_times), detail=VALUES(detail), img_url=VALUES(img_url), d_URL=VALUES(d_URL), start=VALUES(start), end=VALUES(end), give_date=VALUES(give_date), entry=VALUES(entry), note=VALUES(note), cal=VALUES(cal);
            ").execute(n_l[0], n_l[1], n_l[2], n_l[3], n_l[4], n_l[5], n_l[6], n_l[7], n_l[8], n_l[9], n_l[10], n_l[11], n_l[12], n_l[13], n_l[14], n_l[15], n_l[16], n_l[17], n_l[18], n_l[19], n_l[20], n_l[21], n_l[22], n_l[23])
        end
    end


    my.close()

    
rescue => ex
    print ex.message
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    r_json['map'] = ['error']

    print r_json.to_json

end
