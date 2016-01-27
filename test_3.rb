require 'net/http'



# Using Net::HTTP.new actually re-connects
# each time, unexpectedly!
#
# MYTH BUSTED
uri = URI('http://localhost:3005')

http = Net::HTTP.new(uri.host, uri.port)

2.times do
  request = Net::HTTP::Get.new uri
  response = http.request request
  puts "#{response.code} - #{response.body}"
end
