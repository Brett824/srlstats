require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'yaml'

#Get the current SRL data, save it to a YAML file to be used for stats

def generate_error(args, response)
    
    puts "Error!"
    puts response.body
    exit 1

end

#TODO: not hardcode the game, put stuff into functions, whatever.
#now properly find the total number of races so you can easily grab em all, previously was hardcoded
starturi = URI.parse("http://api.speedrunslive.com/pastraces?game=isaac&page=1&season=0&pageSize=1")

http = Net::HTTP.new(starturi.host, starturi.port)

request = Net::HTTP::Get.new(starturi.request_uri)

response = http.request(request)

if response.class != Net::HTTPOK
    
    generate_error(ARGV, response)
    
end

page = response.body

racecount = JSON.parse(page)["count"]

uri = URI.parse("http://api.speedrunslive.com/pastraces?game=isaac&page=1&season=0&pageSize=#{racecount}")

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

if response.class != Net::HTTPOK
    
    generate_error(ARGV, response)
    
end

page = response.body

obj = JSON.parse(page)


File.open('srl.txt', 'w') {|f| f.write(YAML.dump(obj)) }