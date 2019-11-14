library(dplyr)
library(rtweet)
library(stringr)
library(shiny)
library(shinydashboard,quietly = T)
library(shinythemes)
library(glue)
source("init.R")

ui <- dashboardPage(
    skin = "red",
    menuItem("Dashboard",icon = icon("dashboard")),
    dashboardHeader("American Society of Criminology 2019 \n Conference"),
    dashboardSidebar(),
    dashboardBody(
        box(title = "Top 10 Hashtags associated with ASCSF19",
                      plotOutput("hashtag_bar"),
            collapsible = FALSE
            ),
        box(title = "Number of Tweets Associated with ASC")
        )
)
