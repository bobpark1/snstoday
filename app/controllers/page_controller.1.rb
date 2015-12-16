class PageController < ApplicationController
    require 'open-uri'
    require 'date'
    
    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield(max_id)
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    def index

        #facebook parsing
        if user_signed_in?
            @facebook = Page.where(user_id: current_user.id, snstype: 1)
            @fb = [] #post id & like number
            @pid = []
            
            if params[:lst] == nil 
                lst_number = 10
            else 
                lst_number = params[:lst]
            end
            @facebook.each do |p|
                url = "https://graph.facebook.com/#{p.pageid.to_i}/posts?access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo&fields=id,likes.summary(true),updated_time"
                while true
                    #parsing 25 json(newsfeed) data
                    fb_raw = JSON.parse(open(url, &:read))
                    unless fb_raw["data"][-1] == nil
                        fb_raw["data"].each do |d| #managing one post
                            like_number = d["likes"]["summary"]["total_count"]
                            @fb << [p.pageid.to_i, d["id"].split('_')[-1], like_number] #adding post id & like result to the list
                        end
                        #sorting most-liked posts top 10 within the pool
                        @fb = @fb.sort_by{|k| k[2]}.reverse[0, lst_number]
                        #parsing more posts within a day
                        if (Time.now - Time.parse(fb_raw["data"][-1]["updated_time"]))/(24*60*60) < 1
                            url = fb_raw["paging"]["next"]
                        else
                            break
                        end
                    else
                        break
                    end
                end
            end
            
            #twit parsing
            @twitter = Page.where(snstype: 2)
            @twit = [] #post id & count 
            @pid = []
            
            if params[:lst] == nil
                lst_number = 10
            else    
                lst_number = params[:lst]
            end
            @twit.each do |p|
                url = "http://twitter.com/#{p.pageid.to_i}/posts?access_token=259079311-WNQpogoDgkBuU3IjJ3rZZUMzrrIC2qk6jC03vJb9"
                while true
                #parsing 25 json(newsfeed) data
                    twitter_raw = JSON.parse(open(url, &:read))
                    twitter_raw["data"].each do |d| #managing one post
                        like_number = d["count"]
                        @twit << [p.pageid.to_i, d["id"].split('_')[1], like_number] #adding post id & like result to the list
                    end
                    #sorting most-liked posts top 10 within the pool
                    @twit = @twit.sort_by{|k| k[2]}.reverse[0, lst_number]
                    #parsing more posts within a day
                    if (Time.now - Time.parse(twitter_raw["data"][-1]["updated_time"]))/(24*60*60) < 1
                        url = twitter_raw["paging"]["next"]
                    else
                        break
                    end
                end
            end
            
            
            #instagram user parsing
            @instagram = Page.where(snstype: 3)
            @insta = [] #post id & count 
            @pid = []

            if params[:lst] == nil
                lst_number = 10
            else    
                lst_number = params[:lst]
            end
             @instagram.each do |p|
                url = "https://api.instagram.com/v1/tags/#{p.pageid.to_i}/media/recent?access_token=1904087850.1677ed0.184cfc7a076f4c598ddf3637e3d92131"
                while true
                #parsing 25 json(newsfeed) data
                    insta_raw = JSON.parse(open(url, &:read))
                    insta_raw["data"].each do |d| #managing one post
                        like_number = d["likes"]["count"]
                        @insta << [p.pageid.to_i, d["id"].split('_')[1], like_number] #adding post id & like result to the list
                    end
                    #sorting most-liked posts top 10 within the pool
                    @insta = @insta.sort_by{|k| k[2]}.reverse[0, lst_number]
                    #parsing more posts within a day
                    if (Time.now - Time.at(Time.parse(insta_raw["data"][-1]["created_time"])))/(24*60*60) < 1
                        url = insta_raw["paging"]["next"]
                    else
                        break
                    end
                end
            end
        end
    end
    
    def update_page
        if Page.where(user_id: params[:id], pageid: params[:pageid])[0] == nil
            Page.create(user_id: params[:id], snstype: params[:snstype], pagename: params[:pagename], pageid: params[:pageid])
        else
            Page.where(user_id: params[:id], pageid: params[:pageid])[0].destroy
        end
        redirect_to :back
    end
    
    def update_post
        page = Page.where(user_id: params[:user], pageid: params[:page])[0]
        unless page.postid.include?(params[:post]) or page.postid == nil
            page.postid << params[:post]
        else
            page.postid.delete(params[:post])
        end
        page.save
        redirect_to :root
    end
    
    def mypage
        if user_signed_in?
            #search part
            @search = Search.all
    
            #followed page part
            page = Page.where(user_id: current_user.id)
            @result = []
            page.each do |p|
                img = "https://graph.facebook.com/#{p.pageid}/picture/uploaded&access_token=1494493670846068%7Cw0SyXYr6pvYCxt97JPycnTEZOUo"
                @result << [p.pagename, img, p.pageid]
            end
        else
            redirect_to :root
        end
    end
    
    def search
        unless Search.all.empty? #clear all previous record
            Search.all.each do |x|
                x.destroy
            end
        end
        if params[:snstype] == "1"    #facebook search
            url = "https://graph.facebook.com/search?q=#{CGI.escape(params[:name])}&type=page&access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo"
            fb_raw = JSON.parse(open(url, &:read))
            fb_raw["data"].each do |d| #managing one post
                pic_url = "https://graph.facebook.com/#{d["id"]}/picture/uploaded&access_token=1494493670846068%7Cw0SyXYr6pvYCxt97JPycnTEZOUo"
                Search.create(snstype: 1, name: "#{d["name"]}", pid: "#{d["id"]}", url: pic_url)
            end

        elsif params[:snstype] == "2"   #twitter search
            Search.create(name: "!", pid: "!", url: "!")

        else    #instagram search
            url = "https://api.instagram.com/v1/users/search?q=#{CGI.escape(params[:name])}&access_token=1904087850.1677ed0.184cfc7a076f4c598ddf3637e3d92131"
            insta_raw = JSON.parse(open(url, &read))
            insta_raw["data"].each do |d|
                pic = d["data"]["profile_picture"]
                Search.create(snstype: 3, name: "#{d["data"]["full_name"]}", pid: "#{d["id"]}", url: pic)
        end
        
        redirect_to "/mypage"
    end
end
    


        
