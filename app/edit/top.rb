#!/opt/alt/ruby25/bin/ruby
# encoding: utf-8 
require "cgi"
require "json"
require "time"
require 'net/http'
require '/home/c9357042/public_html/tokuppa.com/app/edit/mysql/lib/mysql'

require "csv"
require 'open-uri'

cgi = CGI.new
print cgi.header("text/plain; charset=utf-8")

begin
    now = Time.now
    print now
    print 'top.json'

    url = 'https://docs.google.com/spreadsheets/d/1ZxJTiNvnbl2H0dGAe00bQP0721Y7TTZeEny6vI3R1TU/export?format=csv&gid=0'
    
    check = {}

    CSV.parse(open(url).string) do |n_l|
        if n_l[0] != nil
            if n_l[0] == 'kiyaku'
                check[n_l[0]] = n_l[1].to_i
            else
                check[n_l[0]] = n_l[1]
            end
        end
    
    end
        
    File.open("/home/c9357042/public_html/tokuppa.com/app/check.json", "w:UTF-8") do |n_f|
        JSON.dump(check, n_f) 
    end



    my2 = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_news')
    mywp = Mysql.connect('mysql73.conoha.ne.jp','hhkr8_ruby','app_2022ruby','hhkr8_686nb68x')

    questionnaire_data =["first_question", "second_1_question", "second_2_question", "insyoku_question"]
    
    my2.query("SELECT q_id FROM questionnaire WHERE start<=NOW() AND end>=NOW();").each do|row|
        questionnaire_data.push(row[0].rjust(6, "0"))

    end


    q = {}
    q_index = ["t_id", "c_g", "t_name", "user", "img_url", "app_page", "d_URL", "start", "end", "note"]
    sql_c_data = my2.query("SELECT * FROM top WHERE start<=NOW() AND end>=NOW();")
    sql_c_data.each do|row|
        laa = {}
        for x in 1..q_index.length-1 do
            if row[x] == nil
                laa[q_index[x]] = ''
            else
                laa[q_index[x]] = row[x]
            end
        end
        q[row[0].to_s] = laa
    end 
    my2.close()

    mywp.query("SELECT ID,post_content,post_title,post_excerpt,guid,term_id FROM wp_terms NATURAL JOIN wp_term_taxonomy NATURAL JOIN wp_term_relationships INNER JOIN wp_posts ON wp_term_relationships.object_id=wp_posts.ID WHERE (SELECT term_taxonomy_id FROM wp_term_taxonomy NATURAL JOIN wp_term_relationships WHERE wp_term_relationships.object_id=wp_posts.ID AND wp_term_taxonomy.term_taxonomy_id=8)>0 AND wp_posts.post_status='publish' AND (wp_terms.term_id=437 OR wp_terms.term_id=438) ORDER BY ID DESC;").each do |row|
        laa = {}
        laa["t_id"] = row[0].to_i+10000
        if row[5]=="437"
            laa["c_g"] = 'c'
        else
            laa["c_g"] = 'g'
        end
        laa["t_name"] = row[2]
        laa["user"] = ''
        htmltext = row[1]
        laa["img_url"] = ""
        if htmltext.include?('<img src=')
            laa["img_url"] = URI.encode(htmltext.slice(/<img src=".+" alt/).gsub!('<img src="', '').gsub!('" alt', ''))
        end
        laa["app_page"] = ''
        laa["d_URL"] = row[4]
        laa["iosURL"] = ""
        laa["androidURL"] = ""
        laa["start"] = ""
        laa["end"] = ""
        laa["note"] = ""
        q[(row[0].to_i+10000).to_s] = laa
    end
    mywp.close()

    r_json = {}
    r_json['time'] = Time.now
    
    r_json['data'] = q

    r_json['questionnaire'] = questionnaire_data

        
    File.open("/home/c9357042/public_html/tokuppa.com/app/top.json", "w:UTF-8") do |n_f|
        JSON.dump(r_json, n_f) 
    end

    print r_json

rescue => ex
    print ''
    print ex.message
end

