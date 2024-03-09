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
    print '\n all_campaign'

    all_store = []
    json = ''

    ca_data = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM all_campaign ORDER BY all_campaign.end DESC;").each do |row|
        ca_data.push(row)
    end

    my.close()

    #共通キャンペーン、独自キャンペーンリスト
    point_campaign = {};
    cashless_campaign = {};
    else_campaign = {};
    all_campaign = [];

    point_campaign2 = {};
    cashless_campaign2 = {};
    else_campaign2 = {};
    all_campaign2 = [];

    campaign_index = ["c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal", "os_name"]

    #campaign
    for x in 0..ca_data.length-1 do
        x_list = {}
        for y in 0..campaign_index.length-1 do
            if ca_data[x][y]!=nil && ca_data[x][y] != 0
                if y==4 || y==5 || (7<=y && y<=11)
                    x_list[campaign_index[y]] = ca_data[x][y].to_f
                else
                    x_list[campaign_index[y]] = ca_data[x][y]
                end
            else
                x_list[campaign_index[y]] = ''
            end
        end
        x_list["id"] = x_list["c_id"]
        x_list["s_name"] = "all"
        if (Time.parse(x_list['start'])<=now) && (now<=Time.parse(x_list['end']))
            if ((point_campaign.key?(ca_data[x][1])) ||
                (cashless_campaign.key?(ca_data[x][1]))) then
                if ca_data[x][1].match('^P') then
                    point_campaign[ca_data[x][1]].push(x_list)
                else
                    if (ca_data[x][1].match('^D') || ca_data[x][1].match('^C')) then
                        cashless_campaign[ca_data[x][1]].push(x_list)
                    else
                        else_campaign[ca_data[x][1]].push(x_list);
                    end
                end
                all_campaign.push(x_list)
            else

                if ca_data[x][1].match('^P') then
                    point_campaign[ca_data[x][1]] = [x_list]
                else
                    if (ca_data[x][1].match('^D') || ca_data[x][1].match('^C')) then
                        cashless_campaign[ca_data[x][1]] = [x_list]
                    else
                        else_campaign[ca_data[x][1]] = [x_list]
                    end
                end
                all_campaign.push(x_list);
            end
        else
            #期限外data追加
            """
            if ((point_campaign.key?(ca_data[x][1])) ||
                (cashless_campaign.key?(ca_data[x][1]))) then
                if ca_data[x][1].match('^P') then
                    point_campaign[ca_data[x][1]].push(x_list)
                else
                    if (ca_data[x][1].match('^D') || ca_data[x][1].match('^C')) then
                        cashless_campaign[ca_data[x][1]].push(x_list)
                    else
                        else_campaign[ca_data[x][1]].push(x_list);
                    end
                end
                all_campaign.push(x_list)
            else

                if ca_data[x][1].match('^P') then
                    point_campaign[ca_data[x][1]] = [x_list]
                else
                    if (ca_data[x][1].match('^D') || ca_data[x][1].match('^C')) then
                        cashless_campaign[ca_data[x][1]] = [x_list]
                    else
                        else_campaign[ca_data[x][1]] = [x_list]
                    end
                end
                all_campaign.push(x_list);
            end
            """

            if ((point_campaign2.key?(ca_data[x][1])) ||
                (cashless_campaign2.key?(ca_data[x][1]))) then
                #"""
                if ca_data[x][3].match('^P') then
                    point_campaign2[ca_data[x][3]].push(x_list)
                else
                    if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                        cashless_campaign2[ca_data[x][3]].push(x_list)
                    else
                        else_campaign2[ca_data[x][3]].push(x_list);
                    end
                end
                #"""
                all_campaign2.push(x_list)
            else
                #"""
                if ca_data[x][3].match('^P') then
                    point_campaign2[ca_data[x][3]] = [x_list]
                else
                    if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                        cashless_campaign2[ca_data[x][3]] = [x_list]
                    else
                        else_campaign2[ca_data[x][3]] = [x_list]
                    end
                end
                #"""
                all_campaign2.push(x_list)            
            end
        end
    end



    r = {
        "point_campaign" => point_campaign,
        "cashless_campaign" => cashless_campaign,
        "all_campaign2" => all_campaign2,
    }


    r_json = {}
    r_json['time'] = Time.now

    File.open("/home/c9357042/public_html/tokuppa.com/app/"+"all_campaign_updatetime"+".json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end
    
    r_json['data'] = r

    
    File.open("/home/c9357042/public_html/tokuppa.com/app/all_campaign.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end

    r2 = {
        "all_campaign2" => all_campaign2
    }
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = r2
    File.open("/home/c9357042/public_html/tokuppa.com/app/all_campaign_2.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end





rescue => ex
    print ''
    print ex.message
end

