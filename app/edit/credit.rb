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

    credit_data = ["card_id", "credit_brand", "issuer_name", "issuer_id", "card_d_name", "card_d_id", "card_num", "kind", "way", "w1", "w2", "w3", "rate", "card_d_detail", "card_d_img_url", "card_d_d_url", "card_d_iosurl", "card_id_androidurl", "card_id_note", "p_code", "touch_Pay", "iD", "QUICPay", "ApplePay", "GooglePay", "ThreeDsecure", "child_code", "child_d"]
    c_d = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM credit;").each do|row|
        c_d.push(row)
    end 
    my.close()



    c_h = {}
    c_p = {}
    c_z = {}
    for i in 0..c_d.length-1 do
        c_m = {}
        for j in 0..credit_data.length-1 do
            if c_d[i][j]!=nil #&& p_d[i][j] != 0
                if j==9 || j==10 || j==12
                    c_m[credit_data[j]] = c_d[i][j].to_f
                elsif j==5
                    c_m[credit_data[j]] = c_d[i][j].to_i
                elsif j==14
                    c_m[credit_data[j]] = ''
                else
                    c_m[credit_data[j]] = c_d[i][j]
                end
            else
                c_d[credit_data[j]] = ''
            end
        end
        if c_d[i][7] == 'cci'
            c_h[c_d[i][0]] = c_m
        elsif c_d[i][7] == 'ccp'
            c_p[c_d[i][0]] = c_m
        else
            if c_z.key?(c_d[i][1])
                c_z[c_d[i][1]][c_d[i][0]] = c_m
            else
                c_z[c_d[i][1]] = {}
                c_z[c_d[i][1]][c_d[i][0]] = c_m
            end
        end
    end


    r_json = {}
    r_json['time'] = Time.now

    r_json['data'] = {}
    r_json['data']['credit'] = c_h
    r_json['data']['prepaid'] = c_p
    r_json['data']['pay'] = c_z

    
    File.open("/home/c9357042/public_html/tokuppa.com/app/"+"credit"+".json", "w:UTF-8") do |n_f|
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
