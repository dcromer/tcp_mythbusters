require 'json'

use Rack::ContentLength
run Proc.new { |env| [
  '200',
  {
    'Content-Type' => 'application/json'
  },
  [{ data: true }.to_json]
] }
