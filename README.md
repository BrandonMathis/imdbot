imdbot
======

Reddit Bot that scans /new links for potential movie related discussion. Then comments with Movie descriptions and reviews from IMDB.

:skull: Dead :skull:

Fun while it lasted, worked pretty well, I moved on to more interesting projects.

Feel free to fork and run if you want :)

##How To Run
Get a [Reddit API Key](http://www.reddit.com/dev/api) AND READ THE ACCESS RULE!!!!!
###Start Resqueue
```
$ TERM_CHILD=1 QUEUES="imdbot" rake resque:work
```

###Get some Links from reddit
get 50 links from /r/movies subreddit (most accurate)
```
$ rake get_movie_links
```

get LOTS of rising links from reddit default subreddit
```
$ rake watch_links
```
###Watch the Pretty Colors
The Bot is not configured to post to reddit. Currently it dumps all of it's results into a logfile
```
$ tail -f log/info.log
```
