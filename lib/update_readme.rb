require_relative "../lib/environment"
require_relative "../lib/quote_client"
require "octokit"

client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])

begin
  file = client.contents("lpwanw/lpwanw", path: "README.md")
  readme_content = Base64.decode64(file.content).force_encoding('UTF-8')
  unless readme_content =~ /<!--START_SECTION:auto_commit-->.*<!--END_SECTION:auto_commit-->/m
    readme_content += "<!--START_SECTION:auto_commit--> <!--END_SECTION:auto_commit-->" 
  end

  quote = QuoteClient.new.content_quote

  updated_content = readme_content.sub(/<!--START_SECTION:auto_commit-->.*<!--END_SECTION:auto_commit-->/m, "<!--START_SECTION:auto_commit-->\n#{quote}\n<!--END_SECTION:auto_commit-->")
  client.update_contents(
    "lpwanw/lpwanw",
    "README.md",
    "Update content between auto_commit markers",
    file.sha,
    updated_content
  )
rescue Octokit::NotFound
  puts "File not found!"
  exit
end

