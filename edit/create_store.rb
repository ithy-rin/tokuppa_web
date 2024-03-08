#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require "time"
require 'net/http'
require 'uri'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'
cgi = CGI.new
print cgi.header("text/plain; charset=utf-8")

begin
    now = Time.now
    print now

    all_store = []
    json = ''

    mywp = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_686nb68x')
    my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT s_name FROM store_data;").each do|row|
        all_store.push(row)
    end 

    for d in 0..all_store.length-1 do
        store_name = all_store[d][0]
        #store_sheet = all_store["data"][d]["シートリンク"]
        print store_name
        print '  '+d.to_s+'  '
        #print store_sheet


        name = store_name#.gsub('-', '_')

        store_index = ["name", "id", "s_name", "kana", "group1", "genre1", "genre2", "genre3", "P0001_way", "P0001_w1", "P0001_w2", "P0001_w3", "P0001_rate", "P0002_way", "P0002_w1", "P0002_w2", "P0002_w3", "P0002_rate", "P0003_way", "P0003_w1", "P0003_w2", "P0003_w3", "P0003_rate", "P0004_way", "P0004_w1", "P0004_w2", "P0004_w3", "P0004_rate", "dp1_code", "dp1_way", "dp1_w1", "dp1_w2", "dp1_d", "dp1_rate", "dp2_code", "dp2_way", "dp2_w1", "dp2_w2", "dp2_d", "dp2_rate", "dp3_code", "dp3_way", "dp3_w1", "dp3_w2", "dp3_d", "dp3_rate", "visa_code", "visa_d", "master_code", "master_d", "jcb_code", "jcb_d", "amex_code", "amex_d", "de1_code", "de1_d", "de2_code", "de2_d", "de3_code", "de3_d", "CE0001_way", "CE0001_w1", "CE0001_w2", "CE0001_w3", "CE0001_rate", "CE0002_way", "CE0002_w1", "CE0002_w2", "CE0002_w3", "CE0002_rate", "CE0003_way", "CE0003_w1", "CE0003_w2", "CE0003_w3", "CE0003_rate", "CE0004_way", "CE0004_w1", "CE0004_w2", "CE0004_w3", "CE0004_rate", "CE0005_way", "CE0005_w1", "CE0005_w2", "CE0005_w3", "CE0005_rate", "CE0006_way", "CE0006_w1", "CE0006_w2", "CE0006_w3", "CE0006_rate", "CQ0001_code", "CQ0001_d", "CQ0002_code", "CQ0002_d", "CQ0003_code", "CQ0003_d", "CQ0004_code", "CQ0004_d", "CQ0005_code", "CQ0005_d", "CQ0006_code", "CQ0006_d", "CQ0007_code", "CQ0007_d", "CQ0008_code", "CQ0008_d", "CQ0009_code", "CQ0009_d", "CQ0010_code", "CQ0010_d", "hp_url", "img_url", "app_name", "app_url", "ios_app", "android_app", "Twitter", "Instagram", "LINE", "facebook", "youtube", "find_store_url", "chirashi_url", "campaign_url", "fair_url", "menu_url", "net_url", "cal", "note", "point_h"]

        st_data = []
        campaign_index = ["id", "s_name", "c_id", "card_id", "c_name", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "user", "no_user", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "day", "same_cam", "give_date", "entry", "note", "cal"]
        coupon_index = ["id", "issuer_id", "c_id", "s_name", "name", "top", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "note"]
        ca_data = []
        c_data = []
        my.prepare("SELECT * FROM store_data WHERE s_name=?;").execute(store_name).each do |row|
            st_data = row
        end
        my.prepare("SELECT * FROM campaign_id INNER JOIN campaign ON campaign_id.c_id=campaign.c_id WHERE s_name=? ORDER BY campaign.end DESC;").execute(name).each do |row|
            ca_data.push(row)
        end
        my.prepare("SELECT * FROM coupon_id INNER JOIN coupon ON coupon_id.c_id=coupon.c_id WHERE s_name=? ORDER BY coupon.end DESC;").execute(name).each do |row|
            c_data.push(row)
        end

        index_id = {'point'=> 8, 'dokujipoint'=> 28, 'credit'=> 46, 'dokujiemoney'=> 54, 'emoney'=> 60, 'qrcode'=> 90, 'kihon2'=> 110, 'point_h'=> 129}


        #store
        zyohou = {}
        point = {}
        dokuji_point = {};
        credit = {}
        e_money = {};
        qr_code = {}
        dokuji_emoney = {};

        #基本情報
        for y in 0..7 do
            if st_data[y] != nil
                zyohou[store_index[y]] = st_data[y]
            else
                zyohou[store_index[y]] = ''
            end
        end

        for y in index_id['kihon2']..(index_id['kihon2']+18) do
            if st_data[y] != nil
                zyohou[store_index[y]] = st_data[y]
            else
                zyohou[store_index[y]] = ''
            end
        end 
        
        
        if name == 'lawson' || name=='lawsonstore-100' || name=='natural-lawson'
            if 16 <= now.hour && now.hour <= 23
                st_data[index_id['point']+1*5+2] = 2
                st_data[index_id['point']+1*5+4] = 0.01
                st_data[index_id['point']+2*5+2] = 2
                st_data[index_id['point']+2*5+4] = 0.01
            end
        end

        #ポイント
        point_l = ['P0001', 'P0002', 'P0003', 'P0004']
        point_m = ['way', 'w1', 'w2', 'w3', 'rate']
        for y in 0..3 do
            if st_data[index_id['point']+y*5] != '' && st_data[index_id['point']+y*5] != nil
                pl = {}
                for z in 0..4 do
                    if st_data[index_id['point']+y*5+z] != nil
                        pl[point_m[z]] = st_data[index_id['point']+y*5+z]
                    else
                        pl[point_m[z]] = ''
                    end
                end
                point[point_l[y]] = pl
            end
        end

        #point_h
        if st_data[index_id['point_h']]!=nil
            dokuji_point['point_h'] = st_data[index_id['point_h']]
        else
            dokuji_point['point_h'] = ''
        end
        
        #独自ポイント
        if st_data[index_id['dokujipoint']]!=''||st_data[index_id['dokujipoint']+6]!=''||st_data[index_id['dokujipoint']+12]!=''
            for y in 0..2 do
                if st_data[index_id['dokujipoint']+y*6+1] != '' && st_data[index_id['dokujipoint']+y*6+1] != nil #dp?_way
                    if st_data[index_id['dokujipoint']+y*6] != '' && st_data[index_id['dokujipoint']+y*6] != nil
                        pl = {}
                        for z in 0..4 do
                            if st_data[index_id['dokujipoint']+y*6+z+1] != nil
                                pl[point_m[z]] = st_data[index_id['dokujipoint']+y*6+z+1]
                            else
                                pl[point_m[z]] = ''
                            end
                        end
                        point[st_data[index_id['dokujipoint']+y*6]] = pl
                    end
                end

                if st_data[index_id['dokujipoint']+y*6] != '' && st_data[index_id['dokujipoint']+y*6] != nil
                    if st_data[index_id['dokujipoint']+y*6+4] != nil
                        dokuji_point[st_data[index_id['dokujipoint']+y*6]] = st_data[index_id['dokujipoint']+y*6+4]
                    else
                        dokuji_point[st_data[index_id['dokujipoint']+y*6]] = ''
                    end
                end
            end
            '''
            dp_data = []
            SQLite3::Database.new("store.db") do |db|
                db.transaction(){
                    dp_data = db.execute("SELECT * FROM card_data WHERE card_id=? OR card_id=? OR card_id=?;", st_data[28], st_data[30], st_data[32])
                }
            end
            for x in 0..dp_data.length-1 do
                pl = {}
                for z in 4..9 do
                    pl[point_m[z-4]] = dp_data[x][z]
                end
                dokuji_point[dp_data[x][0]] = pl
            end
            '''
        end
        #card area
        for y in 0..3 do
            if st_data[index_id['credit']+y*2] != '' && st_data[index_id['credit']+y*2] != nil
                if st_data[index_id['credit']+y*2+1] != nil
                    credit[st_data[index_id['credit']+y*2]] = st_data[index_id['credit']+y*2+1]
                else
                    credit[st_data[index_id['credit']+y*2]] = ''
                end
            end
        end
        #電子マネー
        e_money_l = ['CE0001', 'CE0002', 'CE0003', 'CE0004', 'CE0005', 'CE0006']
        e_money_m = ['way', 'w1', 'w2', 'w3', 'rate']
        for y in 0..5 do
            if st_data[index_id['emoney']+y*5] != '' && st_data[index_id['emoney']+y*5] != nil
                pl = {}
                for z in 0..4 do
                    if st_data[index_id['emoney']+y*5+z] != nil
                        pl[e_money_m[z]] = st_data[index_id['emoney']+y*5+z]
                    else
                        pl[e_money_m[z]] = ''
                    end
                end
                e_money[e_money_l[y]] = pl
            end
        end
        #qrcode
        qrlist = ['CQ0001', 'CQ0002', 'CQ0003', 'CQ0004', 'CQ0005', 
            'CQ0006', 'CQ0007', 'CQ0008', 'CQ0009', 'CQ0010']
        qr_m = ['way', 'w1', 'w2', 'w3', 'rate']
        for y in 0..9 do
            if st_data[index_id['qrcode']+y*2] != '' && st_data[index_id['qrcode']+y*2] != nil
                if st_data[index_id['qrcode']+y*2+1] != nil
                    qr_code[qrlist[y]] = st_data[index_id['qrcode']+y*2+1]
                else
                    qr_code[qrlist[y]] = ''
                end
            end
        end

        #独自電子マネー
        if st_data[index_id['dokujiemoney']]!=''||st_data[index_id['dokujiemoney']+2]!=''||st_data[index_id['dokujiemoney']+2]!=''
            for y in 0..2 do
                if st_data[index_id['dokujiemoney']+y*2] != '' && st_data[index_id['dokujiemoney']+y*2] != nil
                    if st_data[index_id['dokujiemoney']+y*2+1] != nil
                        dokuji_emoney[st_data[index_id['dokujiemoney']+y*2]] = st_data[index_id['dokujiemoney']+y*2+1]
                    else
                        dokuji_emoney[st_data[index_id['dokujiemoney']+y*2]] = ''
                    end
                end
            end
            '''
            dp_data = []
            SQLite3::Database.new("store.db") do |db|
                db.transaction(){
                    dp_data = db.execute("SELECT * FROM card_data WHERE card_id=? OR card_id=? OR card_id=?;", st_data[42], st_data[44], st_data[46])
                }
            end
            for x in 0..dp_data.length-1 do
                pl = {}
                for z in 4..9 do
                    pl[point_m[z-4]] = dp_data[x][z]
                end
                dokuji_emoney[dp_data[x][0]] = pl
            end
            '''
        end

        #共通キャンペーン、独自キャンペーンリスト
        point_campaign = {};
        cashless_campaign = {};
        else_campaign = {};
        all_campaign = [];

        point_campaign2 = {};
        cashless_campaign2 = {};
        else_campaign2 = {};
        all_campaign2 = [];


        #campaign
        for x in 0..ca_data.length-1 do
            x_list = {}
            for y in 0..campaign_index.length-1 do
                if ca_data[x][y]!=nil && ca_data[x][y] != 0
                    x_list[campaign_index[y]] = ca_data[x][y]
                else
                    x_list[campaign_index[y]] = ''
                end
            end
            if (x_list['start']<=now) && (now<=x_list['end'])
                """
                if (Time.parse('2099-01-01 00:00')<=x_list['end'])
                    x_list['end'] = ''
                end
                """
                if ((point_campaign.key?(ca_data[x][3])) ||
                    (cashless_campaign.key?(ca_data[x][3]))) then
                    if ca_data[x][3].match('^P') then
                        point_campaign[ca_data[x][3]].push(x_list)
                    else
                        if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                            cashless_campaign[ca_data[x][3]].push(x_list)
                        else
                            else_campaign[ca_data[x][3]].push(x_list);
                        end
                    end
                    all_campaign.push(x_list)
                else

                    if ca_data[x][3].match('^P') then
                        point_campaign[ca_data[x][3]] = [x_list]
                    else
                        if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                            cashless_campaign[ca_data[x][3]] = [x_list]
                        else
                            else_campaign[ca_data[x][3]] = [x_list]
                        end
                    end
                    all_campaign.push(x_list);
                end
            else
                """
                if (Time.parse('2099-01-01 00:00')<=x_list['end'])
                    x_list['end'] = ''
                end
                """
                if ((point_campaign2.key?(ca_data[x][3])) ||
                    (cashless_campaign2.key?(ca_data[x][3]))) then
                    """
                    if ca_data[x][3].match('^P') then
                        point_campaign2[ca_data[x][3]].push(x_list)
                    else
                        if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                            cashless_campaign2[ca_data[x][3]].push(x_list)
                        else
                            else_campaign2[ca_data[x][3]].push(x_list);
                        end
                    end
                    """
                    all_campaign2.push(x_list)
                else
                    """
                    if ca_data[x][3].match('^P') then
                        point_campaign2[ca_data[x][3]] = [x_list]
                    else
                        if (ca_data[x][3].match('^D') || ca_data[x][3].match('^C')) then
                            cashless_campaign2[ca_data[x][3]] = [x_list]
                        else
                            else_campaign2[ca_data[x][3]] = [x_list]
                        end
                    end
                    """
                    all_campaign2.push(x_list);
                end
            end
        end

        coupon = {};
        coupon2 = {};

        #coupon
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
                """
                if (Time.parse('2099-01-01 00:00')<=x_list['end'])
                    x_list['end'] = ''
                end
                """
                if (coupon.key?(c_data[x][1])) then
                    coupon[c_data[x][1]].push(x_list)
                else
                    coupon[c_data[x][1]] = [x_list]
                end
            else
                """
                if (Time.parse('2099-01-01 00:00')<=x_list['end'])
                    x_list['end'] = ''
                end
                """
                if (coupon2.key?(c_data[x][1])) then
                    coupon2[c_data[x][1]].push(x_list)
                else
                    coupon2[c_data[x][1]] = [x_list]
                end

            end
        end



        da = []
        campaign = []
        fair = []
        infomation = []


        news_index = ["n_id", "s_name", "n_id", "card_id", "n_name", "detail", "img_url", "d_URL", "iosURL", "androidURL", "start", "end", "note"]

        sql_c_data = my2.prepare("SELECT * FROM news_id INNER JOIN news ON news_id.n_id=news.n_id WHERE news_id.s_name=? AND end>=NOW();").execute(store_name)
        sql_c_data.each do|row|
            laa = {}
            for x in 1..news_index.length-1 do
                if row[x] == nil
                    laa[news_index[x]] = ''
                else
                    laa[news_index[x]] = row[x]
                end
            end
            infomation.push(laa)
        end 

        mywp.prepare("SELECT ID,post_content,post_title,post_excerpt,guid FROM wp_terms NATURAL JOIN wp_term_taxonomy NATURAL JOIN wp_term_relationships INNER JOIN wp_posts ON wp_term_relationships.object_id=wp_posts.ID WHERE (SELECT term_taxonomy_id FROM wp_term_taxonomy NATURAL JOIN wp_term_relationships WHERE wp_term_relationships.object_id=wp_posts.ID AND wp_term_taxonomy.term_taxonomy_id=8)>0 AND wp_posts.post_status='publish' AND wp_terms.slug=?;").execute(store_name).each do |row|
            laa = {}
            laa["s_name"] = store_name
            laa["n_id"] = row[0]+10000
            laa["card_id"] = ''
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
            infomation.push(laa)
        end


=begin
        c_f_index = ['id', 'タイトル', 'c_タイトル', '詳細', '遷移先URL', 'c_遷移先URL',
            '画像URL', 'c_画像URL', '公開開始日', '最終更新日', '公開終了日', 'c_その他']
        info_index = ['id', 'タイトル', '詳細', '遷移先URL', '画像URL', '公開開始日', '最終更新日', '公開終了日', 'c_その他', 'c_or_f']
        

        SQLite3::Database.new("all_store.db") do |db|
            db.transaction(){
                check = db.execute("SELECT COUNT(*) FROM sqlite_master WHERE TYPE='table' AND name=?;", name)[0][0]
                if check==1
                    sql = "SELECT 最終更新日 FROM " + name + " WHERE id=1;"
                    update = db.execute(sql)[0][0]
                    da = db.execute("SELECT * FROM "+name+" WHERE ((公開開始日<datetime('now','+09:00:00')) AND (最終更新日>=?)) OR ((公開開始日<datetime('now','+09:00:00')) AND (公開終了日>=datetime('now','+09:00:00')))", (update))
                    for x in 0..da.length-1 do
                        x_list = {}
                        for y in 0..c_f_index.length-1 do
                            x_list[c_f_index[y]] = da[x][y]
                        end
                        if da[x][c_f_index.length]=='campaign'
                            campaign.push(x_list)
                        elsif da[x][c_f_index.length]=='fair'
                            fair.push(x_list)
                        end
                    end
                end 
                check = db.execute("SELECT COUNT(*) FROM sqlite_master WHERE TYPE='table' AND name=?;", name+"_info")[0][0]
                if check==1
                    da2 = db.execute("SELECT * FROM "+name+"_info WHERE ((公開開始日<datetime('now','+09:00:00')) AND (公開終了日>=datetime('now','+09:00:00')));")
                    for x in 0..da2.length-1 do
                        x_list = {}
                        for y in 0..info_index.length-1 do
                            x_list[info_index[y]] = da2[x][y]
                        end
                        infomation.push(x_list)
                    end
                end 
            }
        end
=end

        store_name = store_name.gsub('_', '-')

        r = [
            zyohou,
            point,
            dokuji_point,
            credit,
            e_money,
            qr_code,
            dokuji_emoney,
            point_campaign,
            cashless_campaign,
            coupon,
            else_campaign,
            [],#all_campaign,
            campaign,
            fair,
            infomation,
        ];

        r_json = {}
        r_json['time'] = Time.now
        
        r_json['data'] = r

        #print r_json
        print store_name + '完了'
        
        File.open("/home/c9357042/public_html/tokuppa.com/app/store/"+store_name+".json", "w:UTF-8") do |n_f|
            JSON.dump(r_json, n_f) 
        end

        r2 = {
            "coupon2" => coupon2,
            "all_campaign2" => all_campaign2
        }
        r_json = {}
        r_json['time'] = Time.now
        r_json['data'] = r2
        File.open("/home/c9357042/public_html/tokuppa.com/app/store/"+store_name+"_2.json", "w:UTF-8") do |n_f|
            JSON.dump(r_json, n_f) 
        end
    end
    my.close()
    my2.close()
    mywp.close()




rescue => ex
    print ''
    print ex.message
end

