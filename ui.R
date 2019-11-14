library(dplyr)
library(rtweet)
library(stringr)
library(shiny)
library(shinydashboard, quietly = T)
library(glue)
library(lubridate)
source("init.R")
httr::set_config(httr::config(http_version = 0))

ui <- dashboardPage(
    skin = "black",
    dashboardHeader(title = "ASC 19 Tweets"),
    dashboardSidebar(
        sidebarMenu(
        menuItem(text = "Descriptive dashboard",
                 tabName = "descriptive_dashboard", icon = icon("dashboard")),
        menuItem("Tweet Wall",tabName = "tweet_wall", icon = icon("twitter"))
    )),
    dashboardBody(
        tabItems(
        tabItem(tabName = "descriptive_dashboard",
                fluidPage(
                    box(
                        title = "Top 10 Hashtags associated with ASCSF19",
                        plotlyOutput("hashtag_bar"),
                        collapsible = T
                    ),
                    box(
                        title = "Top 10 Tweeters with most replies, likes, and retweets",
                        plotlyOutput("top_10_tweeters"),
                        collapsible = T
                    ),
                    box(
                        title = "Tweets Over Time related to ASC",
                        plotlyOutput("tweets_timeline"),
                        collapsible = T
                    ))),
        tabItem(tabName = "tweet_wall",
                fluidRow(
                    box(
                    title = "Filter tweet wall here",
                    sliderInput(
                        "likes_filter",
                        label = NULL,
                        value = max(asc_tweets$favorite_count),
                        min = min(asc_tweets$favorite_count),
                        max = max(asc_tweets$favorite_count)
                    ),
                    sliderInput(
                        "retweet_filter",
                        label = NULL,
                        value = max(asc_tweets$retweet_count),
                        min = min(asc_tweets$retweet_count),
                        max = max(asc_tweets$retweet_count)
                    ),
                    sliderInput(
                        "slideinput",
                        label = NULL,
                        value = as_date(min(asc_tweets$created_at)),
                        min = as_date(min(asc_tweets$created_at)),
                        max = as_date(max(asc_tweets$created_at))
                    ))
                ),
                fluidRow(
                box(title = "Tweet Wall",width = 20,
                    dataTableOutput("tweets"))))
    ))
)
