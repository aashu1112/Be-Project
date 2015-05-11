module AmazonReview
  class Review
                
    def initialize(html)
      @html = html
      @div = html.next_element.next_element
    end
    
    def prod_size
      # @psize = @div.css('div.tiny b a').text
      # puts @psize
      #doc.css('br').each{ |br| br.replace(" ") }
      # if @psize.empty?
        @psize= @div.css('div.tiny b').text
        @psize=@psize.scan(/\w[0-9GB]+/)[0]
      # end

      if !@psize.nil?
        @psize=@psize.scan(/\w[0-9GB]+/)[0]
      else
        @psize="NA"
      end      
      #puts @psize
      @psize
    end

    def inspect
      "<Review: id=#{id}>"
    end
    
    def id
      @id ||= @html['name']
    end
    
    def url   
      @url ||= "http://www.amazon.com/review/#{id}"
    end
    
    def user_id
      regex = /[A-Z0-9]+/
      @user_id ||= @div.css('a[href^="/gp/pdp/profile"]').first["href"][regex]
    end
    
    def title
      @title ||= @div.css("b").first.text.strip
    end
    
    def date
      @date ||= Date.parse(@div.css("nobr").first.text)
    end
    
    def text
      # remove leading and trailing line returns, tabs, and spaces
      @text ||= @div.css(".reviewText")#.to_s#.text#.first.content#.strip #sub(/\A[\n\t\s]+/,"").sub(/[\n\t\s]+\Z/,"")
      @text.css('br').each{ |br| br.replace(" ") }
      @text=@text.text
      @text.force_encoding('iso-8859-1').encode('utf-8')
    end
    
    def rating
      regex = /[0-9\.]+/
      @rating ||= Float( @div.css("span.swSprite").first['title'][regex] )
    end
    
    def helpful_count
      if helpful_match
        @helpful_count ||= Float(helpful_match.captures[0])
      else
        @helpful_count = 0
      end
      
      @helpful_count
    end

    def helpful_count_total
      if helpful_match
        @helpful_count_total ||= Float(helpful_match.captures[1])
      else
        @helpful_count_total = 0
      end
      
      @helpful_count_total
    end

    def helpfulness
      if helpful_match
        if Float(helpful_match.captures[0])==0
          @helpfulness=0
        else
          @helpfulness ||= Float(helpful_match.captures[1]) - Float(helpful_match.captures[0])
        end 
      else
        @helpfulness = 0
      end
      
      @helpfulness
    end
    
    def helpful_ratio
      if helpful_match
        @helpful_ratio ||= Float(helpful_match.captures[0]) / Float(helpful_match.captures[1])
      else
        @helpful_ratio = 0
      end
      
      @helpful_ratio
    end
    
    def to_hash
      attrs = [:id, :url, :user_id, :title, :date, :text, :rating, :helpful_count, :helpful_ratio]
      attrs.inject({}) do |r,attr|
        r[attr] = self.send(attr)
        r
      end
    end
    
    private
    
    def helpful_match
      @helpful_match ||= @div.text.force_encoding('iso-8859-1').encode('utf-8').match(/(\d+) of (\d+) people/)
    end
  end
end