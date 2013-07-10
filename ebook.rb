# Worker code can be anything you want.
require 'rubygems'
require 'twitter'

require 'twitter_init'
require 'markov'

source_tweets = []

$rand_limit ||= 10

# randomly running only about 1 in $rand_limit times
unless rand($rand_limit) == 0
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
    markov.add_text(twt.text)
  end
  
  tweet = nil
  
  5.times do
    tweet = markov.generate_sentence
    break if !source_tweets.any? {|t| t.text == tweet }
  end
  
  puts "TWEET: #{tweet}"
  
  unless tweet.nil? || tweet == ''
    Twitter.update(tweet)
  end
end

