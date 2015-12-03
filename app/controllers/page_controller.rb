class PageController < ApplicationController
    require 'open-uri'
    require 'date'

    def index
        #facebook search
        #"https://graph.facebook.com/search?q=#{params[:search]}&type=post&access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo"

        #facebook parsing
        facebook = Page.where(snstype: 1)
        @fb = [] #page id & like number
        facebook.each do |page|
            page.pageid.each do |pid|
                url = "https://graph.facebook.com/#{pid}/posts?access_token=1494493670846068|w0SyXYr6pvYCxt97JPycnTEZOUo&fields=id,likes.summary(true),updated_time"
                while true
                    #parsing 25 json(newsfeed) data
                    fb_raw = JSON.parse(open(url, &:read))
                    fb_raw["data"].each do |d| #managing one post
                        like_number = d["likes"]["summary"]["total_count"]
                        @fb << [d["id"].split('_')[1], like_number] #adding post id & like result to the list
                    end
                    #sorting most-liked posts top 10 within the pool
                    @fb = @fb.sort_by{|k| k[1]}.reverse[0, 10]
                    #parsing more posts within a day
                    if (Time.now - Time.parse(fb_raw["data"][-1]["updated_time"]))/(24*60*60) < 1
                        url = fb_raw["paging"]["next"]
                    else
                        break
                    end
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

        end
    end
    
    def mypage
        @fb = []
    end
end
