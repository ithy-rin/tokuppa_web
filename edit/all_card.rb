#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require 'net/http'
require 'time'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'


cgi = CGI.new
print cgi.header("text/json; charset=utf-8")
begin
    all_json = []

    coupon_data = ["issuer_id", "cd_name", "cd_id", "cd_detail", "cd_img_url", "cd_d_url", "cd_iosurl", "cd_androidurl", "cd_note"]
    card_data = ["card_id", "card_d_name", "card_d_id", "kind", "way", "w1", "w2", "w3", "rate", "card_d_detail", "card_d_img_url", "card_d_d_url", "card_d_iosurl", "card_d_androidurl", "card_id_note"]
    co_d = []
    p_d = []
    e_d = []
    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM coupon_data;").each do|row|
        co_d.push(row)
    end 
    my.query("SELECT * FROM card_data WHERE kind='pc' OR kind='pd' OR kind='px';").each do|row|
        p_d.push(row)
    end 
    my.query("SELECT * FROM card_data WHERE kind='cc' OR kind='cct' OR kind='cq' OR kind='ce' OR kind='cd' OR kind='cx';").each do|row|
        e_d.push(row)
    end 
    my.close()



    p_h = {}
    for i in 0..p_d.length-1 do
        p_m = {}
        for j in 0..card_data.length-1 do
            if p_d[i][j]!=nil #&& p_d[i][j] != 0
                if j==5 || j==6 || j==8
                    p_m[card_data[j]] = p_d[i][j].to_f
                elsif j==2
                    p_m[card_data[j]] = p_d[i][j].to_i
                else
                    p_m[card_data[j]] = p_d[i][j]
                end
            else
                p_m[card_data[j]] = ''
            end
        end
        p_h[p_d[i][0]] = p_m
    end
    co_h = {}
    for i in 0..co_d.length-1 do
        co_m = {}
        for j in 0..coupon_data.length-1 do
            if co_d[i][j]!=nil #&& co_d[i][j] != 0
                co_m[coupon_data[j]] = co_d[i][j]
            else
                co_m[coupon_data[j]] = ''
            end
        end
        co_h[co_d[i][0]] = co_m
    end
    e_h = {}
    for i in 0..e_d.length-1 do
        e_m = {}
        for j in 0..card_data.length-1 do
            if e_d[i][j]!=nil #&& e_d[i][j] != 0
                if j==5 || j==6 || j==8
                    e_m[card_data[j]] = e_d[i][j].to_f
                elsif j==2
                    e_m[card_data[j]] = e_d[i][j].to_i
                else
                    e_m[card_data[j]] = e_d[i][j]
                end
            else
                e_m[card_data[j]] = ''
            end
        end
        e_h[e_d[i][0]] = e_m
    end


    r_json = {}
    r_json['time'] = Time.now

    File.open("/home/c9357042/public_html/tokuppa.com/app/"+"all_card_updatetime"+".json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end
    print r_json

    r_json['data'] = {"point" => p_h, "coupon" => co_h, "emoney" => e_h}
    
    File.open("/home/c9357042/public_html/tokuppa.com/app/"+"all_card"+".json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end

    print r_json.to_json

            


rescue => ex
    print ex.message
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    print r_json.to_json
end
