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

    j_d = []
    j_m_d = []
    e_d = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM jichitai WHERE note not like '_DEL' OR note IS NULL;").each do|row|
        j_d.push(row)
    end 
    my.query("SELECT * FROM jichitai_map WHERE (start<NOW()) AND (end>=now()) AND note not like '_DEL' OR note IS NULL;").each do|row|
        j_m_d.push(row)
    end 


    my.close()


    campaign_map = {"j_id" => "INTEGER","card_id" => "TEXT","j_name" => "TEXT","j_num" => "INTEGER","pref" => "TEXT","city" => "TEXT","way" => "TEXT","w1" => "REAL","w2" => "REAL","w3" => "TEXT","rate" => "REAL","min" => "REAL","max_once" => "REAL","max_term" => "REAL","max_times" => "REAL","detail" => "TEXT","img_url" => "TEXT","d_URL" => "TEXT","start" => "TEXT","end" => "TEXT","give_date" => "TEXT","entry" => "TEXT","note" => "TEXT","cal" => "TEXT"}
    campaign_index = ["j_id", "card_id", "j_name", "j_num", "pref", "city", "way", "w1", "w2", "w3", "rate", "min", "max_once", "max_term", "max_times", "detail", "img_url", "d_URL", "start", "end", "give_date", "entry", "note", "cal"]
    campaign_ja = ["id", "カードid", "キャンペーン名", "自治体コード", "都道府県", "市区町村", "手段", "還元1数値", "還元2数値", "還元3文字", "率", "最小金額", "上限/回", "上限/期間", "上限回数", "詳細", "画像URL", "詳細URL", "開始日", "終了日", "付与日", "エントリー", "備考", "カレンダー"]
    c_data = []

    jichitai = {}
    jichitai2 = {}
    count = {}

    for i in 0..j_d.length-1 do
        j_m = {}
        for j in 0..campaign_index.length-1 do
            if j==0 || j==3 
                j_m[campaign_index[j]] = j_d[i][j].to_i
            elsif j==7 || j==8 || (10<=j && j<=14)
                if j_d[i][j] != nil 
                    j_m[campaign_index[j]] = j_d[i][j].to_f
                else
                    j_m[campaign_index[j]] = ''
                end
            else
                if j_d[i][j] != nil 
                    j_m[campaign_index[j]] = j_d[i][j]
                else
                    j_m[campaign_index[j]] = ''
                end
            end
        end

        print j_m['city']

        n = 0
        card_id = j_m['card_id']

        if card_id.include?('CQ')
            n = card_id.slice(2,card_id.length-1).to_i + 20000
        elsif card_id.include?('CE')
            n = card_id.slice(2,card_id.length-1).to_i + 30000
        elsif card_id.include?('CD')
            n = card_id.slice(2,card_id.length-1).to_i + 50000
        end
        n += j_m['j_num']*100000
        """
        if count.key?(j_m['j_num'].to_s.rjust(6, '0'))
            count[j_m['j_num'].to_s.rjust(6, '0')] += 1
            n = count[j_m['j_num'].to_s.rjust(6, '0')] 
        else
            count[j_m['j_num'].to_s.rjust(6, '0')] = j_m['j_num']*100+1
            n = j_m['j_num']*100+1
        end
        """

        n = n*100000 + j_m['j_id']

	y_a = now.year
	m_a = now.month

	if (m_a==12) 
	    y_a +=1 
	    m_a = 1
	else 
	    m_a +=1
	end

        if (Time.parse(j_m['start'])<=Time.local(y_a, m_a, 1, 0, 0, 0)) && (Time.local(now.year, now.month, 1, 0, 0, 0)<=Time.parse(j_m['end']))
            jichitai[n.to_s.rjust(11+5, '0')] = j_m
        else
            jichitai2[n.to_s.rjust(11+5, '0')] = j_m
        end
    end

    j_m_m = {}
    j_m_index = ["j_m_id", "j_m_name", "map_url", "start", "end", "note"]

    if j_m_d.length>0
        for i in 0..j_m_d.length-1 do
            if ((j_m_d[i][3]!='')&&(j_m_d[i][3]!=''))
                if (Time.parse(j_m_d[i][3])<=now) && (now<=Time.parse(j_m_d[i][4]))
                    for j in 0..j_m_index.length-1 do
                        j_m_m[j_m_index[j]] = j_m_d[i][j]
                    end
                end
            end
        end
    end

    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = jichitai.sort.to_h
    r_json['map'] = j_m_m
    File.open("/home/c9357042/public_html/tokuppa.com/app/jichitai/jichitai.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end
    File.open("/home/c9357042/public_html/tokuppa.com/app/jichitai/jichitai_2.json", "w:UTF-8") do |n_f|
        JSON.dump({'o_date': jichitai2}, n_f) 
    end
    
    print r_json.to_json

            
rescue => ex
    print ex.message
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']
    r_json['map'] = ['error']

    print r_json.to_json
end
