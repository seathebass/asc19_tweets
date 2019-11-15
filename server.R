library(shiny)
library(shinydashboard)
library(dplyr)
library(forcats)
library(plotly)
library(igraph)
library(networkD3)
httr::set_config(httr::config(http_version = 0))
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
  output$histo_likes <- renderPlot({
    asc_tweets %>% 
      ggplot(aes(favorite_count))+
      geom_histogram(fill = "red",color = "black",size = .5)+
      theme_minimal()+
      labs(x = "number of likes a tweet received",
           y = "")
  })
  output$histo_rt <- renderPlot({
    asc_tweets %>% 
      ggplot(aes(retweet_count))+
      geom_histogram(fill = "lightblue",color = "black",size = .5)+
      theme_minimal()+
      labs(x = "number of retweets a tweet received",
           y = "")
  })  
  output$tweets <- renderDataTable({
    asc_tweets %>% 
      dplyr::select(screen_name,created_at,text,retweet_count,favorite_count) %>% 
      arrange(desc(created_at)) %>% 
      dplyr::filter(created_at <= as_date(max(input$slideinput)),
                    favorite_count <= max(input$likes_filter),
                    favorite_count >= min(input$likes_filter),
                    retweet_count <= max(input$retweet_filter),
                    retweet_count >= min(input$retweet_filter))
    },escape = F)
  output$network_tweets <- renderForceNetwork({
    test <- network_data1 %>% 
      graph_from_data_frame()
    V(test)$node_label <- unname(ifelse(degree(test)[V(test)] > 20, names(V(test)), "")) 
    V(test)$node_size <- unname(ifelse(degree(test)[V(test)] > 20, degree(test), 0)) 
    test <- test %>% 
      networkD3::igraph_to_networkD3()
    test$nodes <- test$nodes %>% 
      mutate(group = 1)
    networkD3::forceNetwork(
      Links = test$links,
      Nodes = test$nodes,
      NodeID = "name",
      Group = 'group',
      zoom = T,
      fontSize = 12,
      height = 1000,
      width = 1000
    )
  })
}

