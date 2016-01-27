require 'net/http'

# Caling http.request multiple times within a
# Net::HTTP.start block will persist the connection.
#
# MYTH CONFIRMED
uri = URI('http://localhost:3005')

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new uri

  2.times do
    response = http.request request
    puts "#{response.code} - #{response.body}"
  end
end
