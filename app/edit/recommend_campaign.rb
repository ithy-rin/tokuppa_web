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
    now = Time.now

    all_json = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    #my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')

    #mywp = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_686nb68x')

    campaign_index = ["c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal"]
    all_campaign_index = ["c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal", "os_name"]
    news_index = ["n_id", "s_name", "n_id", "card_id", "n_name", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "note"]
    
    use_index = ["card_id", "c_name", "way", "rate", "user", "no_user", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "note", "cal"]

    ca_data = []

    my.query("SELECT * FROM campaign WHERE campaign.start<=NOW() AND campaign.end>=NOW() AND campaign.no_user IS NOT NULL ORDER BY campaign.no_user ASC, campaign.end DESC;").each do|row|
        ca_data.push(row)
    end 

    campaign = []
    for x in 0..ca_data.length-1 do
        x_list = {}

        for y in 0..campaign_index.length-1 do
            cam_index = campaign_index[y]
            if use_index.include?(cam_index)
                if cam_index == 'no_user'
                    cam_index = 'recommend'
                end
                if ca_data[x][y]!=nil && ca_data[x][y] != 0
                    x_list[cam_index] = ca_data[x][y]
                else
                    x_list[cam_index] = ''
                end
            end
        end
        campaign.push(x_list)
    end

    ca_data = []
    my.query("SELECT * FROM all_campaign WHERE all_campaign.start<=NOW() AND all_campaign.end>=NOW() AND all_campaign.no_user IS NOT NULL ORDER BY all_campaign.no_user ASC, all_campaign.end DESC;").each do |row|
        ca_data.push(row)
    end

    #all_campaign
    for x in 0..ca_data.length-1 do
        x_list = {}
        for y in 0..all_campaign_index.length-1 do
            all_cam_index = all_campaign_index[y]
            if use_index.include?(all_cam_index)
                if all_cam_index == 'no_user'
                    all_cam_index = 'recommend'
                end
                if ca_data[x][y]!=nil && ca_data[x][y] != 0
                    if y==4 || y==5 || (7<=y && y<=11)
                        x_list[all_cam_index] = ca_data[x][y].to_f
                    else
                        x_list[all_cam_index] = ca_data[x][y]
                    end
                else
                    x_list[all_cam_index] = ''
                end
            end
        end
        campaign.push(x_list)
    end

    campaign = campaign.sort_by{|v| v['end']}
    campaign = campaign.sort_by{|v| v['recommend']}


    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = {}
    r_json['data']['campaign'] = campaign
    File.open("/home/c9357042/public_html/tokuppa.com/app/recommend_campaign.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end     

    my.close()
    #my2.close()
    #mywp.close()

    print r_json


rescue => ex
    print ex.message
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    print r_json.to_json
end
