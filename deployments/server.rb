require "sinatra"
require "json"
require "octokit"

before do
  request.body.rewind if request.body.size > 0
  @payload = JSON.parse(request.body.read)
end

# Receive webhooks for `deployment` events. When we receive a `deployment` event, we can run the
# deployment command given and report a status.
post "/webhooks" do
  deployment_url = create_initial_deployment(@payload)
  deployment = create_initial_deployment_status(deployment_url)
  `./#{File.dirname(__FILE__)}/script/deploy`
  if success
    client.create_deployment_status(deployment[:url], "success")
  else
    client.create_deployment_status(deployment[:url], "failure")
  end
  200
end

def create_initial_deployment(payload)
  repository = payload["repository"]["full_name"]
  ref = payload["deployment"]["ref"]
  options = {
    task: "deploy",
    auto_merge: true, # Ensure ref is "caught up" with default branch (ie, master)
    required_contexts: [],
    payload: { setting: 1234 },
    environment: "staging",
    description: "Deploying the demo to staging"
  }
  client.create_deployment(repository, ref, options)
end

def success
  $?.exitstatus == 0
end

# You'll need a GitHub token that has `repo:status` scope.
def client
  @client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
end
