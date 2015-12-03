class PageController < ApplicationController
    require 'open-uri'
    require 'date'

    def index
        #facebook search
        #"https://graph.facebook.com/search?q=#{params[:search]}&type=post&access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo"

        #facebook parsing
        facebook = Page.where(snstype: 1)
        @fb = [] #page id & like number
        @fbn = []
        facebook.each do |page|
            page.pageid.each do |pid|
                while true
                    url = "https://graph.facebook.com/#{pid}/posts?access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo&fields=id,likes,updated_time"
                    fb_raw = JSON.parse(open(url, &:read))
                    fb_raw["data"].each do |d|
                        @fb << [d["id"].split('_')[1]]
                    end
                    if (Time.parse(fb_raw["data"][0]["updated_time"])-Time.now)/(24*3600) > 1
                        break
                    end
                    break
                end
            end
        end
        #twit parsing
        twitter = Page.where(snstype: 2)
        @twit = []
        twitter.each do |i|
        end
        #instagram parsing
        instagram = Page.where(snstype: 3)
        @insta = []
        instagram.each do |i|
            insta_raw = open("https://api.instagram.com/v1/tags/#{i.pageid.to_i}/media/recent?access_token=2129843127.1677ed0.383efa51b3a743239e8ff9193da037d0", &:read)
        end
    end
    
    def mypage
        @fb = []
    end
end
