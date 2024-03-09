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

    coupon_data = ["issuer_id", "cd_name", "cd_id", "cd_detail", "cd_img_url", "cd_d_url", "cd_iosurl", "cd_androidurl", "cd_note"]
    card_data = ["card_id", "card_d_name", "card_d_id", "kind", "way", "w1", "w2", "w3", "rate", "card_d_detail", "card_d_img_url", "card_d_d_url", "card_d_iosurl", "card_id_androidurl", "card_id_note"]
    co_d = []
    p_d = []
    e_d = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')
    my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')

    mywp = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_686nb68x')

    my.query("SELECT * FROM coupon_data;").each do|row|
        co_d.push(row)
    end 
    my.query("SELECT * FROM card_data WHERE kind='pc' OR kind='pd' OR kind='px' OR kind='xx';").each do|row|
        p_d.push(row)
    end 
    my.query("SELECT * FROM card_data WHERE kind='cc' OR kind='cct' OR kind='cq' OR kind='ce' OR kind='cd' OR kind='cx';").each do|row|
        p_d.push(row)
    end 

    coupon_index = ["id", "issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "note"]
    co_h = {}
    for i in 0..co_d.length-1 do
        co_m = {}
        for j in 0..coupon_data.length-1 do
            co_m[coupon_data[j]] = co_d[i][j]
        end
        c_data = []
        my.prepare("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id INNER JOIN coupon_data ON coupon_id.issuer_id=coupon_data.issuer_id WHERE coupon_id.issuer_id=?;").execute(co_d[i][0]).each do|row|
            c_data.push(row)
        end 

        coupon = []
        coupon2 = []
        for x in 0..c_data.length-1 do
            x_list = {}
            for y in 1..coupon_index.length-1 do
                if c_data[x][y]!=nil && c_data[x][y] != 0
                    x_list[coupon_index[y]] = c_data[x][y]
                else
                    x_list[coupon_index[y]] = ''
                end
            end
            if (x_list['start']<=now) && (now<=x_list['end'])
                coupon.push(x_list)
            else
                coupon2.push(x_list)
            end
        end
        co_m['campaign'] = coupon

        news = [];

        co_m['news'] = news

        r_json = {}
        r_json['time'] = Time.now
        r_json['data'] = co_m
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+co_d[i][0]+".json", "w:UTF-8") do |n_f|
            JSON.dump(r_json, n_f) 
        end
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+co_d[i][0]+"_2.json", "w:UTF-8") do |n_f|
            JSON.dump({'i_id': co_d[i][0], 'o_date': coupon2}, n_f) 
        end

    end
    campaign_index = ["id", "s_name", "c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal"]
    all_campaign_index = ["c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal", "os_name"]
    news_index = ["n_id", "s_name", "n_id", "card_id", "n_name", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "note"]

    p_h = {}
    for i in 0..p_d.length-1 do
        p_m = {}
        for j in 0..card_data.length-1 do
            p_m[card_data[j]] = p_d[i][j]
        end
        ca_data = []

        my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id WHERE card_id=? ORDER BY campaign.end DESC;").execute(p_d[i][0]).each do|row|
            ca_data.push(row)
        end 

        ca_data2 = []

        campaign = []
        campaign2 = []
        ca_index = []
        ca_index2 = []
        for x in 0..ca_data.length-1 do
            x_list = {}
            if ca_index.include?(ca_data[x][0])
                campaign[ca_index.index(ca_data[x][0])]['s_name'].push(ca_data[x][1])
            elsif ca_index2.include?(ca_data[x][0])
                campaign2[ca_index2.index(ca_data[x][0])]['s_name'].push(ca_data[x][1])
            else
                x_list['s_name'] = [ca_data[x][1]]
                for y in 2..campaign_index.length-1 do
                    if ca_data[x][y]!=nil && ca_data[x][y] != 0
                        x_list[campaign_index[y]] = ca_data[x][y]
                    else
                        x_list[campaign_index[y]] = ''
                    end
                end
                if (x_list['start']<=now) && (now<=x_list['end'])
                    campaign.push(x_list)
                    ca_index.push(ca_data[x][0])
                else
                    campaign2.push(x_list)
                    ca_index2.push(ca_data[x][0])
                end
            end
        end

        ca_data = []
        my.prepare("SELECT * FROM all_campaign WHERE card_id=? ORDER BY all_campaign.end DESC;").execute(p_d[i][0]).each do |row|
            ca_data.push(row)
        end

        #all_campaign
        for x in 0..ca_data.length-1 do
            x_list = {}
            for y in 0..all_campaign_index.length-1 do
                if ca_data[x][y]!=nil && ca_data[x][y] != 0
                    if y==4 || y==5 || (7<=y && y<=11)
                        x_list[all_campaign_index[y]] = ca_data[x][y].to_f
                    else
                        x_list[all_campaign_index[y]] = ca_data[x][y]
                    end
                else
                    x_list[all_campaign_index[y]] = ''
                end
            end
            x_list["id"] = x_list["c_id"]
            x_list["s_name"] = ["all"]
            if (x_list['start']<=now) && (now<=x_list['end'])
                campaign.push(x_list)
                ca_index.push(ca_data[x][0])
            else
                campaign2.push(x_list)
                ca_index2.push(ca_data[x][0])
            end
        end

        campaign = campaign.sort_by{|v| v['end']}
        #campaign2 = campaign2.sort_by{|v| v['end']}

        p_m['campaign'] = campaign

        news = []
        sql_c_data = my2.prepare("SELECT * FROM news_id INNER JOIN news ON news_id.n_id=news.n_id WHERE news.card_id=? AND end>=NOW();").execute(p_d[i][0])
        sql_c_data.each do|row|
            laa = {}
            for x in 1..news_index.length-1 do
                if row[x] == nil
                    laa[news_index[x]] = ''
                else
                    laa[news_index[x]] = row[x]
                end
            end
            news.push(laa)
        end 

        mywp.prepare("SELECT ID,post_content,post_title,post_excerpt,guid FROM wp_terms NATURAL JOIN wp_term_taxonomy NATURAL JOIN wp_term_relationships INNER JOIN wp_posts ON wp_term_relationships.object_id=wp_posts.ID WHERE (SELECT term_taxonomy_id FROM wp_term_taxonomy NATURAL JOIN wp_term_relationships WHERE wp_term_relationships.object_id=wp_posts.ID AND wp_term_taxonomy.term_taxonomy_id=8)>0 AND wp_posts.post_status='publish' AND wp_terms.name=?;").execute(p_d[i][1]).each do |row|
            laa = {}
            laa["s_name"] = ""
            laa["n_id"] = row[0].to_i+10000
            laa["card_id"] = p_d[i][0]
            laa["n_name"] = row[2]
            laa["detail"] = row[3]
            htmltext = row[1]
            laa["img_url"] = ""
            if htmltext.include?('<img src=')
                laa["img_url"] = URI.encode(htmltext.slice(/<img src=".+" alt/).gsub!('<img src="', '').gsub!('" alt', ''))
            end

            laa["d_URL"] = row[4]
            laa["iosURL"] = ""
            laa["androidURL"] = ""
            laa["start"] = ""
            laa["end"] = ""
            laa["note"] = ""
            news.push(laa)
        end

        p_m['news'] = news

        r_json = {}
        r_json['time'] = Time.now
        r_json['data'] = p_m
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+p_d[i][0]+".json", "w:UTF-8") do |n_f|
            JSON.dump(r_json, n_f) 
        end    
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+p_d[i][0]+"_2.json", "w:UTF-8") do |n_f|
            JSON.dump({'i_id': p_d[i][0], 'o_date': campaign2}, n_f) 
        end
    end

    card_rev = {'CC0006'=> 'CC0001', 'CC0007' => 'CC0002', 'CC0008'=>'CC0003', 'CC0009'=>'CC0004'}
    e_h = {}
    for i in 0..e_d.length-1 do
        e_m = {}
        for j in 0..card_data.length-1 do
            e_m[card_data[j]] = e_d[i][j]
        end
        ca_data = []

        my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id WHERE card_id=? ORDER BY campaign.end DESC;").execute(e_d[i][0]).each do|row|
            ca_data.push(row)
        end 
          

        campaign = []
        campaign2 = []
        ca_index = []
        ca_index2 = []
        for x in 0..ca_data.length-1 do
            x_list = {}
            if ca_index.include?(ca_data[x][0])
                campaign[ca_index.index(ca_data[x][0])]['s_name'].push(ca_data[x][1])
            elsif ca_index2.include?(ca_data[x][0])
                campaign2[ca_index2.index(ca_data[x][0])]['s_name'].push(ca_data[x][1])
            else
                x_list['s_name'] = [ca_data[x][1]]
                for y in 2..campaign_index.length-1 do
                    x_list[campaign_index[y]] = ca_data[x][y]
                end
                if (x_list['start']<=now) && (now<=x_list['end'])
                    campaign.push(x_list)
                    ca_index.push(ca_data[x][0])
                else
                    campaign2.push(x_list)
                    ca_index2.push(ca_data[x][0])
                end
            end
        end


        ca_data = []
        my.prepare("SELECT * FROM all_campaign WHERE card_id=? ORDER BY all_campaign.end DESC;").execute(e_d[i][0]).each do |row|
            ca_data.push(row)
        end
        #all_campaign
        for x in 0..ca_data.length-1 do
            x_list = {}
            for y in 0..all_campaign_index.length-1 do
                if ca_data[x][y]!=nil && ca_data[x][y] != 0
                    if y==4 || y==5 || (7<=y && y<=11)
                        x_list[all_campaign_index[y]] = ca_data[x][y].to_f
                    else
                        x_list[all_campaign_index[y]] = ca_data[x][y]
                    end
                else
                    x_list[all_campaign_index[y]] = ''
                end
            end
            x_list["id"] = x_list["c_id"]
            x_list["s_name"] = ["all"]
            if (x_list['start']<=now) && (now<=x_list['end'])
                campaign.push(x_list)
                ca_index.push(ca_data[x][0])
            else
                campaign2.push(x_list)
                ca_index2.push(ca_data[x][0])
            end
        end

        campaign = campaign.sort_by{|v| v['end']}
        #campaign2 = campaign2.sort_by{|v| v['end']}

        e_m['campaign'] = campaign

        news = []
        sql_c_data = my2.prepare("SELECT * FROM news_id INNER JOIN news ON news_id.n_id=news.n_id WHERE news.card_id=? AND end>=NOW();").execute(p_d[i][0])
        sql_c_data.each do|row|
            laa = {}
            for x in 1..news_index.length-1 do
                if row[x] == nil
                    laa[news_index[x]] = ''
                else
                    laa[news_index[x]] = row[x]
                end
            end
            news.push(laa)
        end 
        mywp.prepare("SELECT ID,post_content,post_title,post_excerpt,guid FROM wp_terms NATURAL JOIN wp_term_taxonomy NATURAL JOIN wp_term_relationships INNER JOIN wp_posts ON wp_term_relationships.object_id=wp_posts.ID WHERE (SELECT term_taxonomy_id FROM wp_term_taxonomy NATURAL JOIN wp_term_relationships WHERE wp_term_relationships.object_id=wp_posts.ID AND wp_term_taxonomy.term_taxonomy_id=8)>0 AND wp_posts.post_status='publish' AND wp_terms.name=?;").execute(p_d[i][1]).each do |row|
            laa = {}
            laa["s_name"] = ""
            laa["n_id"] = row[0]+10000
            laa["card_id"] = p_d[i][0]
            laa["n_name"] = row[2]
            laa["detail"] = row[3]
            htmltext = row[1]
            if htmltext.include?('<img src=')
                laa["img_url"] = URI.encode(htmltext.slice(/<img src=".+" alt/).gsub!('<img src="', '').gsub!('" alt', ''))
            end

            laa["d_URL"] = row[4]
            laa["iosURL"] = ""
            laa["androidURL"] = ""
            laa["start"] = ""
            laa["end"] = ""
            laa["note"] = ""
            news.push(laa)
        end

        e_m['news'] = news

        r_json = {}
        r_json['time'] = Time.now
        r_json['data'] = e_m
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+e_d[i][0]+".json", "w:UTF-8") do |n_f|
            JSON.dump(r_json, n_f) 
        end        
        File.open("/home/c9357042/public_html/tokuppa.com/app/card/"+e_d[i][0]+"_2.json", "w:UTF-8") do |n_f|
            JSON.dump({'i_id': e_d[i][0], 'o_date': campaign2}, n_f) 
        end
        print p_d[i]
    end


    my.close()
    my2.close()
    mywp.close()

    r_json = {}
    r_json['time'] = Time.now
    r_json['c'] = card_rev
    
    print r_json.to_json

            
rescue => ex
    print ex.message
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    print r_json.to_json
end
