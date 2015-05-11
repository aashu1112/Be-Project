#There is a command line input => the csv file name with path if necessary.

require 'rubygems'
require 'engtagger'
require "csv"

class MyEngTagger < EngTagger
	
	VBN = get_ext('vbn')
	RB  = get_ext('rb')
	NNS = get_ext('nns')

	
	def init_service_words(file_name)
		@serv_wrd=File.open("#{file_name}","r").read.split("\n")
	end

	def init_features
		@features=["camera","microphone","battery"]
	end


	def feature_extract(review)
		ret = {}
		phrase_ext=/(?:#{JJ}){1}(?:#{NN}|(?:#{NNP})){1}|

					(?:#{NN}){1}(?:#{JJ}){1}|

					(?:#{RB}){1}(?:#{NN}|(?:#{NNS}))+|

					(?:#{RB})+(?:#{JJ})+(?:#{NN}|(?:#{NNP}))|

					(?:#{NN}){1}(?:#{RB}){1}(?:#{VB}|(?:#{VBN})){1}|

					(?:#{NN}){1}(?:#{VBN}){1}|

					(?:#{NN}|(?:#{NNS}))+(?:#{VBG}){1}|

					(?:#{NN}){1}(?:#{VBZ}){1}(?:#{NN}){1}|

					(?:#{NN}|(?:#{NNP})){1}(?:#{DET}){1}(?:#{JJ}|(?:#{JJR})){1}|

					(?:#{NN}){1}(?:#{VBZ}){1}(?:#{RB})|

					(?:#{NN}){1}(?:#{VBG}|(?:#{JJ})|(?:#{RB}))+					
					/xo

		review.split(".").each do |sentence|
			if !sentence.empty? && @features.any? { |w| sentence.include?(w) }
				tagged = add_tags(sentence)
				readable = get_readable(sentence)
				scanned = tagged.scan(phrase_ext)

				scanned.each do |mn_phrase|
					k = strip_tags(mn_phrase)
					if k.include?("camera")
						if ret["camera"].nil?
							ret["camera"]=[]
							ret["camera"] << k
						else
							ret["camera"] << k
						end

					elsif k.include?("microphone")
						if ret["microphone"].nil?
							ret["microphone"]=[]
							ret["microphone"] << k
						else
							ret["microphone"] << k
						end

					elsif k.include?("battery")
						if ret["battery"].nil?
							ret["battery"]=[]
							ret["battery"] << k
						else
							ret["battery"] << k
						end
					else
					end
				end
			end
		end
		return ret
	end

	def load_senti_wrds(file)
		@senti_hash=Hash.new
		File.readlines(file).each do |line|
			line=line.split(",")
			@senti_hash[line[0]]=line[1].to_i
		end
	end

	def load_phrases(file)
		@phrase_hash=Hash.new
		File.readlines(file).each do |line|
			line=line.split(",")
			@phrase_hash[line[0]]=line[1].to_i
		end
	end


	def polarize(text_hash)
		ret={}
		text_hash.each do |k,v|
			v.each do |sentence|
				if ret[k].nil?
					ret[k] = 0
					ret[k] += polarize_text(sentence)
				else
					ret[k] += polarize_text(sentence)
				end
			end
		end	

		ret.each do |k,v|
			if v < -1
				ret[k] = -1
			elsif v > 1
				ret[k] = 1
			end
		end

		rows = "#{ret["camera"]},#{ret["battery"]},#{ret["microphone"]}"
	end

	def polarize_text(text)
		if @phrase_hash[text]
			return @phrase_hash[text]
		end
		tokens = text.split(" ")
		sentiment_total = 0.0
		tokens.each do |token|
			sentiment_value = @senti_hash[token]
			if sentiment_value
	  			sentiment_total += sentiment_value
			end	
		end
		sentiment_total
	end

	def service_test(review)
		review=review.tr('.', '')
		review=review.split(" ")
		ret= @serv_wrd & review

		if review.length < 15
			return true if ret.length>0
		elsif review.length >15 
			return true if ret.length>2
		else
			return false
		end
	end

	def feature_test(review)
		review=review.split(" ")
		ret = @features & review
		return true if ret.length>0
		return false
	end

#end of class......
end



tgr=MyEngTagger.new

tgr.init_features
tgr.init_service_words("service_wrds.txt")
tgr.load_senti_wrds("sentiment_words.txt")
tgr.load_phrases("phrase_senti.txt")

op=File.open("Final_op.csv", "w")

stopwrd_file=File.open("stop_wrds.txt","r").read
stopwords=stopwrd_file.split("\n")

count=0



op.write("Sr.No.,UID,Date,Rating,Helpful_yes,Helpful_tot,Helpful_no,Size,Title,Review,Class,Camera,Battery,Microphone")
op.write("\n")
File.readlines(ARGV[0]).each do |rows|
	row=rows.split(",")
	count+=1
	rows[rows.length-1]=""
	# puts "#{rows[rows.length-1]=="\n"}"
	# abort()

	review = row[9]
	title =  row[8]

	if tgr.service_test(title)|| tgr.service_test(review)
		rows += ",SERVICE,,,,"
		
	elsif tgr.feature_test(review)
		rows += ",FEATURE,"
		review=review.split(" ").delete_if{|x| stopwords.include?(x)}.join(" ")
		feature_op=tgr.feature_extract(review)
		if !feature_op.empty?
			temp = tgr.polarize(feature_op)
			rows += temp
		else
			rows += ",PRODUCT,,,,"
		end
	else	
		rows += ",PRODUCT,,,,"	
	end
	op.write(rows)
	op.write("\n")
	puts "#{count}"

end
