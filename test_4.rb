require 'net/http'

# Repeatedly invoking Net::Http#start also
# creates new connections, unexpectedly!
#
# MYTH BUSTED
uri = URI('http://localhost:3005')

http = Net::HTTP.new(uri.host, uri.port)

2.times do
  http.start do |connection|
    request = Net::HTTP::Get.new uri
    response = connection.request request
    puts "#{response.code} - #{response.body}"
  end
end
