# Worker code can be anything you want.
require 'rubygems'
require 'twitter'

require 'twitter_init'
require 'markov'

source_tweets = []

$rand_limit ||= 10

puts "PARAMS: #{params}" if params.any?

unless params.key?("tweet")
  params["tweet"] = true
end

# randomly running only about 1 in $rand_limit times
unless rand($rand_limit) == 0 || params["force"]
  puts "Not running this time"
else
  # Fetch a thousand tweets
  begin
    user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :exclude_replies => false, :include_replies => true)
    max_id = user_tweets.last.id
    source_tweets += user_tweets.reject {|t| t.text =~ /(http:\/\/)|(\bRT\b)|(\bMT\b)|@/ }
  
    25.times do
      user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :max_id => max_id - 1, :exclude_replies => false, :include_replies => true)
      max_id = user_tweets.last.id
      source_tweets += user_tweets.reject {|t| t.text =~ /(http:\/\/)|(\bRT\b)|(\bMT\b)|@/ }
    end
  rescue
  end
  
  puts "#{source_tweets.length} tweets found"
  
  markov = MarkovChainer.new(2)
  
  source_tweets.each do |twt|
    text = twt.text
    text.gsub!(/\#[\w\d]+/, '')  # remove hashtags
    markov.add_text(text)
  end
  
  tweet = nil
  
  5.times do
    tweet = markov.generate_sentence
    break if !tweet.nil? && tweet.length < 140 && !source_tweets.any? {|t| t.text =~ /#{tweet}/ }
  end
  
  if params["tweet"]
    if !tweet.nil? && tweet != ''
      puts "TWEET: #{tweet}"
      Twitter.update(tweet)
    else
      raise "ERROR: EMPTY TWEET"
    end
  else
    puts "DEBUG: #{tweet}"
  end
end

