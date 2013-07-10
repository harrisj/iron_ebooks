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
8. Upload to iron.io with `iron_worker upload ebook`
9. Run it with `iron_worker queue ebook` a few times
10. You can schedule it now to run regularly using the scheduler. I'd suggest once every 53 minutes or so.
