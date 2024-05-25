require_relative "../lib/environment"
require_relative "../lib/quote_client"
require "octokit"
require "pry"

missing = false
%w[API_KEY GITHUB_ACCESS_TOKEN].each do |key|
  unless ENV[key]
   missing = true
   puts "Missing ENV #{key}"
  end
end

exit if missing

access_token = ENV["GITHUB_ACCESS_TOKEN"]
client = Octokit::Client.new(access_token: access_token)
start_marker = '<!--START_SECTION:auto_commit-->'
end_marker = '<!--END_SECTION:auto_commit-->'

quote = QuoteClient.new.content_quote

github_username = ENV["GITHUB_USERNAME"] || client.user.login
github_repo = ENV["GITHUB_REPO"] || github_username
file_path = ENV["FILE_PATH"] || "README.md"
content_pattent = /<!--START_SECTION:auto_commit-->.*<!--END_SECTION:auto_commit-->/m
commit_msg = ENV["COMMIT_MSG"] || "Update new quote"

begin
  file = client.contents(
    "#{github_username}/#{github_repo}", 
    path: file_path
  )

  readme_content = Base64.decode64(file.content).force_encoding('UTF-8')

  unless readme_content =~ content_pattent
    readme_content += "#{start_marker}/n#{end_marker}" 
  end

  updated_content = readme_content.sub(
    content_pattent, 
    "#{start_marker}\n#{quote}\n#{end_marker}"
  )

  client.update_contents(
    "#{github_username}/#{github_repo}",
    file_path,
    commit_msg,
    file.sha,
    updated_content
  )
  puts "Update success"
rescue Octokit::NotFound
  puts "File not found!"
  exit
end
