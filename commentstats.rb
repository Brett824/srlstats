require 'yaml'

##not much, just counts the amount of run comments containing a specific word


m = YAML.load(File.read('srl.txt'))

knife = 0
totalcomments = 0
m["pastraces"].each do |race|

		if race["date"].to_i > 1388534400
			race["results"].each do |result|

				if result["message"].include? "knife"
					puts result["message"]	
					knife += 1
				end

				if result["message"].strip != ""
					totalcomments += 1
				end

			end
		end

end

puts "#{knife} / #{totalcomments}"