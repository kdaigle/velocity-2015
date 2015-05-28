require "json"
require "httparty"

push_payload = File.read(File.dirname(__FILE__) + "/push_payload_sample.json")

puts "Sending push payload to app..."
HTTParty.post("http://localhost:4567/webhooks", :body => push_payload)
puts "Done."
