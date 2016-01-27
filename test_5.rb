require 'net/http/persistent'

# Using net/http/persistent gem
# will re-use the existing connection
# correctly.
uri = URI('http://localhost:3005')

http = Net::HTTP::Persistent.new 'my_app'

2.times do
  request = Net::HTTP::Get.new uri
  response = http.request uri, request
  puts "#{response.code} - #{response.body}"
end
