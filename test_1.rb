require 'net/http'


# Calling Net::HTTP.start over and over
# opens and closes tcp connections.
#
# MYTH CONFIRMED
def make_request
  uri = URI('http://localhost:3005')
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    response = http.request request
    puts "#{response.code} - #{response.body}"
  end
end

2.times { make_request }
