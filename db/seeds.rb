# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# test id

User.create(email: 'test@gmail.com', password: 00000000)

Page.create(user_id: 1, snstype: 1, pagename: "서울대학교 대나무숲", pageid: "560898400668463", postid: [])