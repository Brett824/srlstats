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
uri = URI.parse("http://api.speedrunslive.com/pastraces?game=isaac&page=1&season=0&pageSize=2607")

http = Net::HTTP.new(uri.host, uri.port)

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

if response.class != Net::HTTPOK
    
    generate_error(ARGV, response)
    
end

page = response.body

obj = JSON.parse(page)

File.open('srl.txt', 'w') {|f| f.write(YAML.dump(obj)) }