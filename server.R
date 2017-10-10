library(shiny)
library(plotly)


shinyServer(function(input, output) {
  #MAP: Created via Plotly and customized map from Mapbox
  
  output$map <- renderPlotly({
    
    nyc_p %>%
      filter(., hours >= input$slider_hours[1] &
               hours <= input$slider_hours[2]) %>%
      # filter(., popularity ==c(input$twitter_populairity)) %>%
      filter(., dayofweek == c(input$dayof_week)) %>%
      
      plot_mapbox(lat= ~latitude, lon = ~longitude, split = ~timeofday,
                  mode ="scattermapbox", showlegend = TRUE) %>%
      layout(mapbox = list(style = 'mapbox://styles/kennethhansen/cj8duk48d89uy2slg0carws4a',
                           zoom = 12,
                           center = list(lat = ~median(latitude),
                                         lon = ~median(longitude)))) %>%
     
       #Enabling the user to change the layout of the map: Day, Night and Satelite
      layout(updatemenus = list(
        
        list(type='buttons',
              direction = "right",
              yanchor = "bottom",
              x = 1,
              y = 0,
              buttons=list(basic,dark,satellite)) )
             
             )
   
    
  })

#MAP RELATED:
  #Histogram Map: Changing according to the user selection
  
  ##Reactive
  populardf <- reactive({
    nyc_p %>%
      group_by(., popularity, sex, timeofday, hours, dayofweek) %>%
      summarise(., checkin = n()) %>%
      filter(., hours >= input$slider_hours[1] &
               hours <= input$slider_hours[2]) %>%
      # filter(., popularity ==c(input$twitter_populairity)) %>%
      filter(., dayofweek == c(input$dayof_week))
    
  })
  
  #The Histogram
  output$popular <- renderPlotly({
    plot_ly(data = populardf(), x = ~popularity, y = ~checkin,
            type = "bar",
            name = ~sex, color = ~sex) %>%
      layout(yaxis = list(title = 'Count', xaxis = ""), barmode = 'stack') %>%
      layout(legend = list(x = 0.0, y = 1.2))%>%
      layout(legend = list(orientation = 'h'))
  })

  
  
##Where are people going tab###
  #Currently to slow: Inserted a pictuce instead
# output$where <- renderPlot({
#   ggmap(get_map("manhattan", zoom=13, maptype="terrain")) + #Types of maps: https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
#     geom_density2d(data = nyc_p, 
#     aes(x = longitude, y = latitude), size = 0.3) + 
#     stat_density2d(data = nyc_p, aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = "polygon") + 
#     scale_fill_gradient(low = "green", high = "red") + scale_alpha(range = c(0, 0.3), guide = FALSE)
# })

#TREND RELATED TAB
##TAB: Trending Twttter checkin
  
#The overall Trend:
output$general <- renderPlot({
  nyc_p %>%
    group_by(., yr_month) %>%
    summarise(., count = n()) %>%
    ggplot(aes(x = yr_month, y = count, group =1)) +
    geom_point(size = 3.0, color = "grey")+
    geom_line(size = 2, color = "grey") +
    xlab("Months") +
    ylab("Number of check-ins") +
    ggtitle("NYC Twitter check-ins over time") +
    theme_solarized() +
    theme(plot.title = element_text(size=20, 
                                    face="bold",
                                    hjust = 0.5))
  
  
})
  
#Trend for SEX:
  output$dev <- renderPlot({
    nyc_p %>%
      group_by(., yr_month, sex) %>%
      summarise(., count = n()) %>%
      ggplot(aes(x = yr_month, y = count, group = sex, color = sex)) +
      geom_point(size = 3.0)+
      geom_line(size = 2)+
      xlab("Months") +
      ylab("Number of check-ins") +
      ggtitle("Twitter Check-ins Female Versus Male")+
      theme_solarized() +
      theme(plot.title = element_text(size=20, 
                                      face="bold",
                                      hjust = 0.5))
  
  })
  

#Trend Popular Versus Non-Popular:
  output$pop <- renderPlot({
    nyc_p %>%
      group_by(., yr_month, popularity) %>%
      summarise(., count = n()) %>%
      filter(., popularity != "NA") %>%
      ggplot(aes(x = yr_month, y = count, group = popularity, color = popularity)) +
      geom_point(size = 3.0)+
      geom_line(size = 2)+
      xlab("Months") +
      ylab("Number of check-ins")+
      ggtitle("Twitter Check-ins Popular Versus Non-popular")+
      theme_solarized() +
      theme(plot.title = element_text(size=20, 
                                      face="bold",
                                      hjust = 0.5))
    
  })


  
#RELATED TO LOCATION TAB:
  
#TAB: Checkin location
  output$stacked <- renderPlot({
    filtered %>%
    ggplot(aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) +
      geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
      coord_flip()+
      ggtitle("Twitter Top 20 Check-in Places NYC") +
      labs(y = "Number of check-ins", x = "Places")+
      theme_solarized() +
      scale_fill_brewer(palette='Set1') +
      theme(plot.title = element_text(size=20, 
                                      face="bold",
                                      hjust = 0.5))
    
  })
  

#MALE: Stackedbar chart
  # output$sex <- renderPlot({
  #   sexmale %>%
  #     ggplot(aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  #     geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  #     coord_flip()+
  #     labs(title="Males top20 twitter checkin location ", y = "Number of checkins", x = "Places")+
  #     theme_solarized() +
  #     scale_fill_brewer(palette='Set1')
  # )}
  
  
# map style buttons
  basic <- list(method = "relayout",
                args = list(list(mapbox.style = "mapbox://styles/kennethhansen/cj8duk48d89uy2slg0carws4a")),
                label = "Basic")
  
  dark <- list(method = "relayout",
               args = list(list(mapbox.style = "dark")),
               label = "Dark")
  
  satellite <- list(method = "relayout",
                    args = list(list(mapbox.style = "satellite")),
                    label = "Satellite")
  
 })
