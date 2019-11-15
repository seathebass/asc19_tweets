library(dplyr)
library(rtweet)
library(stringr)
library(shiny)
library(shinydashboard, quietly = T)
library(glue)
library(lubridate)
library(httr)
library(plotly)
library(networkD3)
source("init.R")
httr::set_config(httr::config(http_version = 0))

ui <- dashboardPage(
    skin = "black",
    dashboardHeader(title = "ASC 19 Tweets"),
    dashboardSidebar(sidebarMenu(
        menuItem(
            text = "Descriptive dashboard",
            tabName = "descriptive_dashboard",
            icon = icon("dashboard")
        ),
        menuItem("Tweets", tabName = "tweet_data", icon = icon("twitter")),
        menuItem(
            "Network of Tweets",
            tabName = "network",
            icon = icon("connectdevelop")
        )
    )),
    dashboardBody(tabItems(
        tabItem(tabName = "descriptive_dashboard",
                fluidPage(
                    infoBox(title = "Total number of Tweets",
                            value = sum(tweets_time$tweets)),
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
                    ),
                    box(
                        title = "Distribution of Likes Across Tweets",
                        plotOutput("histo_likes")
                    ),
                    box(
                        title = "Distribution of Retweets Across Tweets",
                        plotOutput("histo_rt")
                    )
                )),
        tabItem(tabName = "tweet_data",
                fluidRow(
                    box(
                        title = "Filter tweets here",
                        sliderInput(
                            "likes_filter",
                            label = NULL,
                            value = c(
                                min(asc_tweets$favorite_count) + 1,
                                max(asc_tweets$favorite_count) - 1
                            ),
                            min = min(asc_tweets$favorite_count),
                            max = max(asc_tweets$favorite_count)
                        ),
                        sliderInput(
                            "retweet_filter",
                            label = NULL,
                            value = c(
                                min(asc_tweets$retweet_count) + 1,
                                max(asc_tweets$retweet_count) - 1
                            ),
                            min = min(asc_tweets$retweet_count),
                            max = max(asc_tweets$retweet_count)
                        ),
                        sliderInput(
                            "slideinput",
                            label = NULL,
                            value = c(as_date(min(
                                asc_tweets$created_at
                            ))),
                            min = as_date(min(asc_tweets$created_at)),
                            max = as_date(max(asc_tweets$created_at))
                        )
                    )),
                    fluidRow(box(
                        title = "Tweets",
                        width = 20,
                        dataTableOutput("tweets")
                    )
                )),
                tabItem(
                    "network",
                    fluidRow(box(
                        title = "Tweet Network",
                        tags$p("you can zoom in and out on the network"),
                        forceNetworkOutput("network_tweets"),
                        width = 20
                    ))
                )
        )
        )
    )