require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'yaml'

#TODO: average time difference
#1st and 2nd place completed, time diff
#number of 2 person races (2 person races -> higher win %?)

def generate_error(args, response)
    
    puts "Error! Check API Key and retry."
    puts response.body
    #File.open("../../../error.log", 'a+') {|f| f.write("---\n#{Time.now}\nArgs: #{args[0]}, #{args[1]}, #{args[2]}\n#{response.body}\n---\n") }
    exit 1

end

#get time in HH:MM:SS format
def proper_time(time)
	Time.at(time).gmtime.strftime('%R:%S')
end

class Player

	attr_accessor :name, :avg, :pb, :wins, :losses, :forfeits, :total, :stdev, :tsdif

	def to_s
		"#{name}\n \tavg time: #{proper_time(avg)} \n\tmin time: #{proper_time(pb)} \n\tstd dev (secs): #{stdev} \n\tTrue Skill lost/gained: #{tsdif}\n\tRecord: W: #{wins}, L: #{losses}, F: #{forfeits}, T: #{total} (#{((wins.to_f / total.to_f) * 100).round(2)}%)"
	end

end

playerlist = []

m = YAML.load(File.read('srl.txt'))

players = {}

count = 0

names = {}

categories = {}

biggest = -1
biggestobj = nil

m["pastraces"].each do |p|

	#count amount of race per category/goal
	if categories[p["goal"]].nil?
		categories[p["goal"]] = 1
	else
		categories[p["goal"]] += 1
	end

	if p["goal"].include?("ballsofsteel") && p["goal"].include?("chest") #TODO: not hardcoded goals
	#if p["goal"].include?("chest") 	&& !p["goal"].include?("balls") 
		count += 1
		if p["numentrants"] > biggest #track the biggest race
			biggest = p["numentrants"]	
			biggestobj = p
		end
		#each player gets all their result objects in their own array in a hash table
		p["results"].each do |r|
			if players[r["player"]].nil?
				players[r["player"]] = []
				players[r["player"]].push r
			else
				players[r["player"]].push r
			end
		end
	end
end

#wins.sort_by { |n, w| w }

=begin
categories.each do |k,v|
	puts "#{k}: #{v}"
end
=end

players.each do |w,v|

	#merge these all into one loop, eventually
	#right now just seperate for clarity

	#first place finish count
	wins = v.inject(0) do |a, e|
		if e["place"] == 1 
			a+1
		else
			a
		end
	end

	#count how many times the person didn't forfeit
	finishes = 0
	time = v.inject(0) do |a,e|
		if e["place"] < 9998
			finishes += 1
			a + e["time"]
		else
			a
		end
	end

	#find their fastest finish time
	min  = 1.0/0.0
	v.each do |e|
		if e["place"] < 9998
			if e["time"] < min 
				min = e["time"]
			end
		end
	end

	#find true skill/rating difference in the current set of races
	diff = 0
	v.each do |e|
		diff += e["trueskillchange"]
	end

	#if they didnt finish ignore em
	if finishes == 0 
		next 
	end

	#create a new player object for the player's stats
	#a constructor looked really messy, broke it into individual lines
	p1 = Player.new
	p1.name = w
	p1.avg = time/finishes
	p1.pb = min
	p1.wins = wins
	p1.losses = finishes - wins
	p1.forfeits = v.length - finishes
	p1.total = v.length
	p1.tsdif = diff

	#calculate standard deviation
	stdsum = 0
	v.each do |e|
		if e["place"] < 9998
			stdsum += (e["time"] - p1.avg) ** 2
		end
	end
	p1.stdev = Math.sqrt(stdsum.to_f/finishes.to_f).to_i

	playerlist.push p1

end

#general stats
total_time = 0
total_results = 0
total_finishes = 0
players.each do |k, v| 
	v.each do |e|
		if e["place"] < 9998
			total_finishes += 1
			total_time += e["time"]
		end
		total_results += 1
	end
end
stdsum = 0
mean = total_time/total_finishes
players.each do |k, v| 
	v.each do |e|
		if e["place"] < 9998
			stdsum += (e["time"] - mean) ** 2
		end
	end
end

#output
puts "Overall:"
puts "\tAverage: #{proper_time(total_time/total_finishes)}"
puts "\tStd. Dev.: #{proper_time(Math.sqrt(stdsum/total_finishes).to_i)}"
puts "\tForfeit %: #{100 - ((total_finishes.to_f / total_results.to_f) * 100).round(2)}"
puts "\tAverage racers per race: #{total_results / count}"
puts "\tMost racers in one race: #{biggest}"

puts

#sort players by total races
playerlist.sort! do |x,y|
	x.total <=> y.total
end

puts "Individual:"
puts
puts playerlist.reverse