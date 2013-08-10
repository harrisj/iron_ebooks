# Iron_ebooks

A simple and hackish ruby script for pseudorandomly posting to a _ebooks account tweets derived from a regular twitter account

## Setup

1. Signup for iron.io
2. Create a project at iron.io for doing ebooks tweets
3. Save the iron.json file locally to this directory
4. Signup for a Twitter account you want to use for ebooking things
5. Sign into dev.twitter.com with the same credentials
6. Create an application for your _ebooks account (generate the credentials)
7. Create a file named twitter_init.rb in this directory with the OAuth credentials and the source account you want to use for seeding the markov process
8. Run "bundle install"
9. Upload to iron.io with `bundle exec iron_worker upload ebook`
10. Run it with `bundle exec iron_worker queue ebook` a few times
11. You can schedule it now to run regularly using the scheduler. I'd suggest once every 53 minutes or so.

## Configuring

There are several parameters that control the behavior of the bot. You can override them by setting them in the twitter_init.rb file. 

```
$rand_limit = 10
```

The bot does not run on every invocation. It runs in a pseudorandom fashion whenever `rand($rand_limit) == 0`. You can override it to make it more or less frequent. To make it run every time, you can set it to 0. You can also bypass it on a single invocation by passing `-p '{"force": true}'`

```
$include_urls = false
```

By default, the bot ignores any tweets with URLs in them because those might just be headlines for articles and not text you've written. If you want to use them, you can set this parameter to true.

```
$markov_index = 2
```

The Markov index is a measure of associativity in the generated Markov chains. I'm not going to go into the theory, but 1 is generally more incoherent and 3 is more lucid. If you want to change this, though.


## Debugging

You can force it to bypass the random running by passing up a payload to queue
```
iron_worker queue ebook -p '{"force": true}'
```

You can also make it run without tweeting by setting the tweet param to false
```
iron_worker queue ebook -p '{"force": true, "tweet": false}'
```