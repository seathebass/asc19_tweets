library(igraph)
library(rtweet)
library(dplyr)
library(tidyr)
library(shiny)
library(simpleCache)
library(purrr)
library(lubridate)
library(tsibble)
library(tidytext)
# creating a cache --------------------------------------------------------
setCacheDir("data")
cacheFile <- "data/asc_tweets.rds"
TWEET_REFRESH_ENABLED <- FALSE
# function to get ASC tweets ----------------------------------------------
obtain_new_tweets <- function(max_id) {
  #phrases relevant to ASC
  phrases <- c("ASCSF19", "ASC19", "ASCRM41")
  phrases_to_search <- paste(phrases,collapse = " OR ")
  asc_tweets <- search_tweets(phrases_to_search,n = 1e5,max_id = max_id)
  asc_tweets %>% 
    mutate(
      hashtags = map(hashtags,tolower)
    )
}

needs_pulled <- FALSE
if (file.exists(cacheFile)) {
  cacheTime = file.info(cacheFile)$mtime
  cacheAge = difftime(Sys.time(), cacheTime, units="min")
  initRAge = difftime(Sys.time(), file.info('init.R')$mtime, units = 'min')
  needs_pulled <- (as.numeric(cacheAge) > 15 | as.numeric(initRAge) < as.numeric(cacheAge)) && TWEET_REFRESH_ENABLED
  asc_tweets <- readRDS(cacheFile)
} else {
  asc_tweets <- NULL
  cacheAge <- 0
  needs_pulled <- TRUE
}

if(needs_pulled){
  max_id <- if(as.numeric(cacheAge) < 60) asc_tweets$status_id
  if(!is.null(max_id)){
    max_id <- max(max_id)
    message("collecting tweets starting with ",max_id)
  }
  new_tweets <- obtain_new_tweets(max_id)
  if(!is.null(asc_tweets)){
    asc_tweets <- bind_rows(      
      semi_join(new_tweets, asc_tweets, by = 'status_id'), # updates old tweets
      anti_join(asc_tweets, new_tweets, by = 'status_id'), # keeps old tweets
      anti_join(new_tweets, asc_tweets, by = 'status_id')  # adds new tweets
    ) %>% 
      arrange(desc(created_at))
  } else {
    asc_tweets <- arrange(new_tweets, desc(created_at))
  }
  saveRDS(asc_tweets, "data/asc_tweets.rds")
  cacheTime <- Sys.time()
}

simpleCache("top_10_hashtags", {
  asc_tweets %>%
    mutate(hashtag = unlist(map(hashtags,  ~ paste(., collapse = " , ")))) %>%
    select(hashtag) %>%
    unnest_tokens(word, hashtag, "words") %>%
    count(word, sort = T) %>%
    filter(word != "na") %>%
    top_n(10)
},recreate = needs_pulled)

simpleCache("top_10_tweeters",{
  asc_tweets %>% 
    select(screen_name,favorite_count,retweet_count,reply_count,is_retweet) %>% 
    filter(is_retweet == F) %>% 
    modify_if(is.integer,~if_else(is.na(.),0,as.double(.))) %>% 
    group_by(screen_name) %>% 
    mutate(engagement = favorite_count+retweet_count+reply_count) %>% 
    select(screen_name,engagement) %>% 
    arrange(desc(engagement)) %>% 
    top_n(10)
} 
)

simpleCache("tweets_time",{
asc_tweets %>% 
  as_tsibble(index = created_at,validate = FALSE) %>% 
  index_by(time = as_date(created_at)) %>% 
  summarise(tweets = n())
})
simpleCache("network_data1",{
test <- asc_tweets %>%
  filter(retweet_count > 0) %>% 
  select(screen_name,mentions_screen_name) %>% 
  unnest(mentions_screen_name) %>%
  filter(!is.na(mentions_screen_name)) 
})

