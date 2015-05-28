require "sinatra"
require "json"
require "octokit"

before do
  request.body.rewind if request.body.size > 0
  @payload = JSON.parse(request.body.read)
end

# The ID for the team we'd like to add
GITHUB_TEAM_ID = 123

# Receive webhooks for `repository` events. When we receive a `repository` event, let's add
# one of the teams we know we'll need: 'engineering'.
post "/webhooks" do
  create_initial_team(@payload)
  200
end

def create_intial_team(payload)
  repository = payload["repository"]["full_name"]
  client.add_team_repository(GITHUB_TEAM_ID, repository)
end

# You'll need a GitHub token that has `repo:status` scope.
def client
  @client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
end
