require "open-uri"
require "rss"

# It's a good practice to declare your application's name and contact information
# as recommended by the SEC.
user_agent = "Ergun_Ltd (ergun@me.com)"

URI.open("https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0001045810&type=10-Q%25&dateb=&owner=include&start=0&count=40&output=atom",
  "User-Agent" => user_agent) do |raw|
  feed = RSS::Parser.parse(raw)

  title = case feed
  when RSS::Rss
    feed.channel.title
  when RSS::Atom::Feed
    feed.title.content
  end

  puts "Successfully fetched feed titled: '#{title}'"
  puts "Feed: #{feed}"
end


# Note: The SEC's RSS feed may not always be available or may change over time.
# Ensure you handle exceptions and errors appropriately in production code.
# https://mgmarlow.com/til/2025-03-30-reading-rss-feeds/
