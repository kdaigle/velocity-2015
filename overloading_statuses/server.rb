require "sinatra"
require "json"
require "octokit"

before do
  request.body.rewind if request.body.size > 0
  @payload = JSON.parse(request.body.read)
end

# Receive webhooks for `push` events. When we receive a `push` event, let's make sure
# that our project setup script still builds as expected and report a status to the repository.
post "/webhooks" do
  create_initial_status(@payload)
  200
end

def create_initial_status(payload)
  repository = payload["repository"]["full_name"]
  sha = payload["after"]
  options = {
    context: "velocity-demo",
    target_url: "https://velocity-demo.example.com/sha/#{sha}",
    description: "We are building the application now..."
  }
  client.create_status(repository, sha, "pending", options)
  `./#{File.dirname(__FILE__)}/setup_script.sh`
  if success
    options = {
      context: "velocity-demo",
      target_url: "https://velocity-demo.example.com/sha/#{sha}",
      description: "The application built successfully!"
    }
    client.create_status(repository, sha, "success", options)
  else
    options = {
      context: "velocity-demo",
      target_url: "https://velocity-demo.example.com/sha/#{sha}",
      description: "The application failed to be built successfully!"
    }
    client.create_status(repository, sha, "failure", options)
  end
end

def success
  $?.exitstatus == 0
end

# You'll need a GitHub token that has `repo:status` scope.
def client
  @client ||= Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
end
