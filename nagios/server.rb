require "sinatra"
require "json"
require "octokit"

before do
  request.body.rewind if request.body.size > 0
  @payload = JSON.parse(request.body.read)
end

# Received from alert script or potentially pulled off a queue.
post "/webhooks" do
  client.create_issue(repo, title, body, attributes)
  200
end

# You'll need a GitHub token that has `repo:status` scope.
def client
  @client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
end
