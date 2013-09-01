# encoding: UTF-8

require 'rubygems'
require 'twitter'
require 'punkt-segmenter'
require 'twitter_init'
require 'markov'

source_tweets = []

$rand_limit ||= 10
$markov_index ||= 2

puts "PARAMS: #{params}" if params.any?

unless params.key?("tweet")
  params["tweet"] = true
end

rand_key = rand($rand_limit)

CLOSING_PUNCTUATION = ['.', ';', ':', '?', '!']

def random_closing_punctuation
  CLOSING_PUNCTUATION[rand(CLOSING_PUNCTUATION.length)]
end

def filtered_tweets(tweets)
  include_urls = $include_urls || params["include_urls"]
  include_replies = $include_replies || params["include_replies"]
  source_tweets = tweets.map {|t| t.text.gsub(/\b(RT|MT) .+/, '') }

  if !include_urls
    source_tweets = source_tweets.reject {|t| t =~ /(https?:\/\/)/ }
  end

  if !include_replies
    source_tweets = source_tweets.reject {|t| t =~ /^@/ }
  end

  source_tweets.each do |t| 
    t.gsub!(/(\#|(h\/t)|(http))\S+/, '')
    t.gsub!(/^(@[\d\w_]+\s?)+/, '')
    t += "." if t !~ /[.?;:!]$/
  end

  source_tweets
end

# randomly running only about 1 in $rand_limit times
unless rand_key == 0 || params["force"]
  puts "Not running this time (key: #{rand_key})"
else
  # Fetch a thousand tweets
  begin
    user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :exclude_replies => false, :include_rts => false)
    max_id = user_tweets.last.id
    source_tweets += filtered_tweets(user_tweets)
  
    # Twitter only returns up to 3200 of a user timeline, includes retweets.
    17.times do
      user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :max_id => max_id - 1, :exclude_replies => false, :include_rts => false)
      puts "MAX_ID #{max_id} TWEETS: #{user_tweets.length}"
      break if user_tweets.last.nil?
      max_id = user_tweets.last.id
      source_tweets += filtered_tweets(user_tweets)
    end
  rescue
  end
  
  puts "#{source_tweets.length} tweets found"

  if source_tweets.length == 0
    raise "Error fetching tweets from Twitter. Aborting."
  end
  
  markov = MarkovChainer.new($markov_index)

  tokenizer = Punkt::SentenceTokenizer.new(source_tweets.join(" "))  # init with corpus of all sentences

  source_tweets.each do |twt|
    sentences = tokenizer.sentences_from_text(twt, :output => :sentences_text)

    # sentences = text.split(/[.:;?!]/)

    # sentences.each do |sentence|
    #   next if sentence =~ /@/

    #   if sentence !~ /\p{Punct}$/
    #     sentence += "."
    #   end

    sentences.each do |sentence|
      next if sentence =~ /@/
      markov.add_sentence(sentence)
    end
  end
  
  tweet = nil
  
  10.times do
    tweet = markov.generate_sentence

    tweet_letters = tweet.gsub(/\P{Word}/, '')
    next if source_tweets.any? {|t| t.gsub(/\P{Word}/, '') =~ /#{tweet_letters}/ }

    # if rand(3) == 0 && tweet =~ /(in|to|from|for|with|by|our|of|your|around|under|beyond)\p{Space}\w+$/ 
    #   puts "Losing last word randomly"
    #   tweet.gsub(/\p{Space}\p{Word}+.$/, '')   # randomly losing the last word sometimes like horse_ebooks
    # end

    if tweet.length < 40 && rand(10) == 0
      puts "Short tweet. Adding another sentence randomly"
      next_sentence = markov.generate_sentence
      tweet_letters = next_sentence.gsub(/\P{Word}/, '')
      next if source_tweets.any? {|t| t.gsub(/\P{Word}/, '') =~ /#{tweet_letters}/ }

      tweet += random_closing_punctuation if tweet !~ /[.;:?!]$/
      tweet += " #{markov.generate_sentence}"
    end

    if !params["tweet"]
      puts "MARKOV: #{tweet}"
    end

    break if !tweet.nil? && tweet.length < 110
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

