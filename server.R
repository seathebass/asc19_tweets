library(shiny)
library(shinydashboard)
library(dplyr)
library(forcats)
library(plotly)
server <- function(input,output){
  output$hashtag_bar <- renderPlotly({
    p <- top_10_hashtags %>% 
      ggplot(aes(fct_reorder(word,n),n,text = word))+
      geom_col(fill = "red")+
      coord_flip()+
      theme_minimal()+
      labs(x = "hashtag",
           y = "times hashtag appears")
    ggplotly(p,tooltip = c("y")) 
  })
  output$top_10_tweeters <- renderPlotly({
    z <- top_10_tweeters %>% 
      ggplot(aes(fct_reorder(screen_name,engagement),engagement))+
      geom_col(fill = "orange")+
      coord_flip()+
      theme_minimal()+
      labs(x = "Tweeter",
           y = "Sum of likes, retweets, and replies")
    ggplotly(z,tooltip = c("y"))
  })
  output$tweets_timeline <- renderPlotly({
    t <- tweets_time %>% 
      ggplot(aes(time,tweets))+
      geom_line(color = "blue")+
      theme_minimal()+
      labs(x = "date")+
      theme(axis.title.y = element_blank())
    ggplotly(t,tooltip = "y")
      } 
  )
  output$tweets <- renderDataTable({
    asc_tweets %>% 
      dplyr::select(screen_name,created_at,text,retweet_count,favorite_count) %>% 
      arrange(desc(created_at)) %>% 
      dplyr::filter(created_at <= as_date(max(input$slideinput)),
                    favorite_count <= input$likes_filter,
                    retweet_count <= input$retweet_filter)
    },escape = F)
}

