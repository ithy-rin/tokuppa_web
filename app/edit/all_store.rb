#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'
require 'net/http'
cgi = CGI.new
print cgi.header("text/json; charset=utf-8")
begin




    table_index = ["name", "id", "s_name", "kana", "group1", "genre1", "genre2", "genre3", 
        "P0001_w", nil, nil, nil, nil, "P0002_w", nil, nil, nil, nil, 
        "P0003_w", nil, nil, nil, nil, "P0004_w", nil, nil, nil, nil, 
        "dp1_c", nil, nil, nil, nil, nil, "dp2_c", nil, nil, nil, nil, nil, "dp3_c", nil, nil, nil, nil, nil, 
        "visa_c", nil, "master_c", nil, "jcb_c", nil, "amex_c", nil, 
        "de1_c", nil, "de2_c", nil, "de3_c", nil, 
        "CE0001_w", nil, nil, nil, nil, "CE0002_w", nil, nil, nil, nil, 
        "CE0003_w", nil, nil, nil, nil, "CE0004_w", nil, nil, nil, nil, 
        "CE0005_w", nil, nil, nil, nil, "CE0006_w", nil, nil, nil, nil, 
        "CQ0001_c", nil, "CQ0002_c", nil, "CQ0003_c", nil, 
        "CQ0004_c", nil, "CQ0005_c", nil, "CQ0006_c", nil, 
        "CQ0007_c", nil, "CQ0008_c", nil, "CQ0009_c", nil, 
        "CQ0010_c", nil, 
        nil, "img_url", nil, nil, nil, nil, 
        nil, nil, nil, nil, nil, nil, 
        nil, nil, nil, nil, nil, nil, "note"]



    shopdata = {} #[]
    tabledata = []

    my = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_store')

    my.query("SELECT * FROM store_data;").each do|row|
        tabledata.push(row)
    end 
    my.close()

    for k in 0..tabledata.length-1 do
        ctable = tabledata[k];
        h_c_shopdata = {}

        for l in 0..ctable.length-1 do
            if table_index[l] != nil then
                if ctable[l] == nil then
                    if l<=7 || l>=98
                        h_c_shopdata[table_index[l]] = ''
                    else
                        
                    end
                else
                    h_c_shopdata[table_index[l]] = ctable[l]
                end
            end
        end
        shopdata[ctable[2]] = h_c_shopdata
        #shopdata.push(h_c_shopdata)
    end

    r_json = {}
    r_json['time'] = Time.now
    #更新時間
    File.open("/home/c9357042/public_html/tokuppa.com/app/all_store_updatetime.json", "w:UTF-8") do |f|
        JSON.dump(r_json, f) 
    end

    r_json['data'] = shopdata

    print r_json.to_json

    File.open("/home/c9357042/public_html/tokuppa.com/app/all_store.json", "w:UTF-8") do |f|
        JSON.dump(r_json, f) 
    end





rescue => ex
    r_json = {}
    r_json['time'] = Time.now
    r_json['data'] = ['error']

    print r_json.to_json
end


=begin
    独自point変更前
    table_index = ["name", "id", "s_name", "kana", "group1", "genre1", "genre2", "genre3", 
        "P0001_way", nil, nil, nil, nil, "P0002_way", nil, nil, nil, nil, 
        "P0003_way", nil, nil, nil, nil, "P0004_way", nil, nil, nil, nil, 
        "dp1_code", "dp1_d", "dp2_code", "dp2_d", "dp3_code", "dp3_d", 
        "visa_code", "visa_d", "master_code", "master_d", "jcb_code", "jcb_d", "amex_code", "amex_d", 
        "de1_code", "de1_d", "de2_code", "de2_d", "de3_code", "de3_d", 
        "CE0001_way", nil, nil, nil, nil, "CE0002_way", nil, nil, nil, nil, 
        "CE0003_way", nil, nil, nil, nil, "CE0004_way", nil, nil, nil, nil, 
        "CE0005_way", nil, nil, nil, nil, "CE0006_way", nil, nil, nil, nil, 
        "CQ0001_code", "CQ0001_d", "CQ0002_code", "CQ0002_d", "CQ0003_code", "CQ0003_d", 
        "CQ0004_code", "CQ0004_d", "CQ0005_code", "CQ0005_d", "CQ0006_code", "CQ0006_d", 
        "CQ0007_code", "CQ0007_d", "CQ0008_code", "CQ0008_d", "CQ0009_code", "CQ0009_d", 
        "CQ0010_code", "CQ0010_d", 
        "hp_url", "img_url", "app_name", "app_url", "ios_app", "android_app", 
        "Twitter", "Instagram", "LINE", "facebook", "youtube", "find_store_url", 
        "chirashi_url", "campaign_url", "fair_url", "menu_url", "net_url", "cal", "note"]


    table_index = ["店名", "row", "コード", "業態", "Tポイント", nil, nil, "ポンタ", nil, nil, "dポイント", nil, nil, "楽天ポイント", nil, nil, nil, nil, nil, 
                    "Visa", "Mastercard", "JCB", "AMEX", nil, "交通系ICカード", nil, nil, "WAON", nil, nil, "nanaco", nil, nil, "楽天Edy", nil, nil, "iD", nil, nil, "QUICPay", nil, nil, nil, nil, nil, 
                    "PayPay", "d払い", "auPay", "LINEPay", "楽天Pay", "メルペイ", "J-CoinPay", "ゆうちょPay", "smartcode", "QUOカードPay", nil, 
                    "スマートニュース", "グノシー", "LINEクーポン", "dポイントアプリ", "ガッチャモール", nil, nil, nil, nil, 
                    "HP", "ロゴURL", "アプリ名", "iPhoneアプリURL", "AndroidアプリURL", "Twitter", "Instagram", "LINE", "チラシ", nil, 
                    "店舗検索", "キャンペーン", "フェア", "メニュー", nil, nil, nil, nil, nil, nil, 
                    "チャットリンク", "シートリンク", "カレンダーid", "ブログURL", 
                    "アルファベット", "ひらがな", "グループ", "ジャンル1", "ジャンル2", nil]
    """
    for l in 0..tabledata[0]['c'].length-1 do
        ctable = tabledata[0]['c']
        if ctable[l] == nil then
            table_index.push(nil)
        else
            table_index.push(ctable[l]['v'])
        end
    end
    """
=end