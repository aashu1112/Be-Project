# THE PROGRAM TAKES AS INPUT (COMMAND LINE) THE NAME OF "FOLDER_NAME" WHERE THE HTML PAGES ARE FOLLOWED BY NUMBER OF "PAGES"
 
require 'nokogiri'
require 'open-uri'

module AmazonReview
  def self.find_reviews(page_content)
    reviews = []

    doc = Nokogiri::HTML(page_content)
    new_reviews = 0
    doc.css("#productReviews td > a[name]").each do |review_html|
      reviews << Review.new(review_html)
      new_reviews += 1
    end  

    reviews  
  end
end
require_relative "review"

op_file_Dir=ARGV[0]
no_pages=ARGV[1].to_i

out_file=File.open("#{op_file_Dir}.csv", "w")
count=0

(1..no_pages).each do |pg|
  pg=pg.to_s
  puts pg
  f=File.open("#{op_file_Dir}/#{pg}", "r").read
  review =  AmazonReview.find_reviews(f)
  #r=review.first
  review.each do |r|
    count+=1
    puts "============== #{count} ================"
    date=r.date
    user_id=r.user_id
    rating=r.rating
    help_yes=r.helpful_count
    help_tot=r.helpful_count_total
    help_ratio=r.helpfulness
    prod_size=r.prod_size
    title=r.title.downcase.split(",").join(" ")
    review_text=r.text.downcase.split(",").join(" ")

    title = title.tr('-!)"?#:!$&(_\'', '')
    review_text=review_text.tr('-!)"?#:!$&(_\'', '')

    title = title + "."
    review_text=review_text+"."


    #puts "#{count},#{date},#{user_id},#{rating},#{help_yes},#{help_tot},#{help_ratio},#{prod_size},#{title},#{review_text}\n"

    out_file.write("#{count},#{user_id},#{date},#{rating},#{help_yes},#{help_tot},#{help_ratio},#{prod_size},#{title},#{review_text}\n")
    #abort()
  end
end




# #B00O4WTPOC
# review =  AmazonReview.find_reviews(19)
# r=review.first

# puts r.date
# puts r.helpful_count
# puts r.helpful_ratio
# puts r.helpful_count_total
# #puts "========================================="
# #print review
