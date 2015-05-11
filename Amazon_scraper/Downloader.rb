require 'open-uri'
require "nokogiri"

module AmazonReview

  def self.find_reviews(asin)
    reviews = []
    delay = 0.5
    page = 1
    last_page=0

    %x(mkdir #{asin})

    if last_page==0
      url = "http://www.amazon.com/product-reviews/#{asin}/?ie=UTF8&showViewpoints=0&pageNumber=#{page}&sortBy=bySubmissionDateAscending"
      doc = open(url).read.force_encoding('iso-8859-1').encode('utf-8')
      puts "--- #{page} ---"
      File.open("#{asin}/#{page}",'w+').write(doc)

      doc = Nokogiri::HTML(doc)
      last_page=doc.css('div.CMpaginate span').text.split("›")[0].scan(/...+ (\d+) | Next/)[0][0]
      last_page=last_page.to_i
    end


    # iterate through the pages of reviews
    (2..last_page).each do |page|
      begin
        url = "http://www.amazon.com/product-reviews/#{asin}/?ie=UTF8&showViewpoints=0&pageNumber=#{page}&sortBy=bySubmissionDateAscending"
        doc = open(url).read.force_encoding('iso-8859-1').encode('utf-8')
        File.open("#{asin}/#{page}",'w+').write(doc)  
        puts "--- #{page} ---"  
      rescue Exception => e
        puts delay
        sleep delay
        delay += 0.5
      end
      
    end

#     begin
#       url = "http://www.amazon.com/product-reviews/#{asin}/?ie=UTF8&showViewpoints=0&pageNumber=#{page}&sortBy=bySubmissionDateAscending"
#       doc = open(url).read
# #      

      


#       f=File.open("#{asin}/#{page}",'w+')
#       f.write(doc)


#       # go to next page
#       page += 1
      
#       # delay to prevent 503 errors
#       delay = [0, delay - 0.1].max # decrease delay
#       sleep delay
      
#     rescue Exception => e # error while parsing (likely a 503)      
#       delay += 0.5 # increase delay
    
#     end 
  
  end

end

AmazonReview.find_reviews('B0097CZJEO')


