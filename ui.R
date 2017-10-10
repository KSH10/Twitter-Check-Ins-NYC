library(shiny)
library(shinydashboard)
library(shinythemes)


# Define UI for application that draws a histogram

shinyUI(navbarPage("Twitter Check-Ins",
                   theme = shinytheme("flatly"), #themes: https://rstudio.github.io/shinythemes/
                   
                   ###OVerview###
                   # tabPanel("Overview"),
                   
                   #### MAP NYC ###
                   tabPanel("New York", icon = icon("map"),
                            
                            div(class="outer",
                                tags$head(#customized CSS
                                  includeCSS("styles.css")),
                            
                            tags$style(type = "text/css", "#map {
                                position: fixed; 
                                       top: 41px;
                                       left: 0;
                                       right: 0;
                                       bottom: 0;
                                       overflow: hidden;
                                       padding: 0;}")),
                            
                            plotlyOutput(outputId = "map", width="100%", height="100%"),       
                            
                            
                            
                            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                          top = 120, left = "auto", right = 140, bottom = "auto",
                                          width = 320, height = "auto",
                                          h2("Twitter Check-Ins NYC"),
                                          
                                          
                                          
                                          # # S3
                                          sliderInput(inputId = "slider_hours", label = ("Hour range"), min = 0, max = 24,
                                                     value = c(0,24)),
                                          
                                          
                                          #S1
                                          # selectizeInput("twitter_populairity", label ="Select box"),
                                          #              choices = c("popular","non-popular"))
                                          
                                          # dateRangeInput("daterange",
                                          #                label = 'Date range',
                                          #                start = Sys.Date() - 2, end = Sys.Date() + 2)

                                          
                                          #S2
                                          selectizeInput("dayof_week", label = ("Day of Week"),
                                                         choices = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
                                                                     "Saturday", "Sunday"), selected = "Saturday")
                                         
                            
                                          
                           
                                                        
                                                        
                                          
                                          
                                    
                                         
                          ),
                          
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE, draggable = TRUE, 
                                        top = 320, left = 20, right = "auto" , bottom = "auto",
                                        width = 320, height = "auto",
                                        plotlyOutput(outputId = "popular", height = 300, width = 300))),
                   
                   
                   tabPanel("Manhattan", icon = icon("search-plus"),
                            fluidRow(
                              column(4,
                                     h2("Manhattans own Bermuda Triangle..."),
                                     p("Zooming in at Manhattan, Twitters users seems to check-in more frequently at the lower part of Manhattan. Do you know why? 
                                        If not, head to the Top 20 check-in locations in NYC to figure out why.
                                       ")),
                              
                              column(8,
                                     h2(""),
                                     # plotOutput("where")
                                     img(src="Heat.png", width="800", height="600")
                                     
                                     ))
                            
                   ),
                            
                   
                   
                   ### TRENDING TAB: ###
                   navbarMenu("Trends", icon = icon("line-chart"),
                   tabPanel("Twitter Check-Ins", icon = icon("twitter"),
                            fluidRow(
                              column(4,
                                     h2("Twitter Check-Ins are declining"),
                              p("Twitter check-ins are declining. The ten months sampling period reveals that twitter check-ins per month reached a peak in May 2012 of about 5250 check-ins 
                                and had since declined to 1000 check-ins at the end of the sampling period. Even though, the graph clearly exemplifies that Twitter check-in has decreased significantly 
                                during the sampling period, the results should not be considered as generalizable due to the limited sampling period (April 2012 - February 2013) and an imbalanced dataset. 
                                Thus, it could indicate that Twitter check-in is not that popular as it used to be. The development of check-ins during the sampling period could further reveal a slightly seasonal 
                                pattern where people tend to be more active in respect to check-in the early spring and around Christmas time.")),
                              
                              column(8,
                                     h2(""),
                                      plotOutput("general")))
                              
                              ),
                   
                                     # plotOutput("dev")))),
                                     # img(src="TwitterCheckin.png", width="800", height="400", alt="This is alternate text")))
                            
                  tabPanel("Female vs. Male", icon = icon("venus-mars"),
                           fluidRow(
                             column(4,
                                    h2("Males are checking more in than Females"),
                                    p("Really? Males seem to be significantly more active on Twitter when it comes to check-ins compared to females. Thus, it should be highlighted that the sample favors males considerably, 
                                        and could be a part of the explanation. Males check-in activity on Twitter seems to cause the fluctuation as we observe on the previous graph. Females number of check-ins on Twitter seems to be consistent over the sampling period without any noticeable fluctuations.
                                      ")),
                             
                             column(8, 
                                    h2(""),
                             plotOutput("dev"))
                             
                           )),
                  
                  tabPanel("Popular vs. Non-popular", icon=icon("user-o"),
                           fluidRow(
                             column(4,
                                    h2("Can social-status explain numbers of check-ins?"),
                                    p("Peoples social status seems to influence the number of check-ins on Twitter. The graph clearly illustrates that non-popular people (people with fewer followers than following) tend to check-in more 
                                      than people with a higher social status on the social media Twitter. Are Twitter check-ins annoying in the newsfeed?")),
                             
                            column(8,
                                   h2(""),
                            plotOutput("pop"))
                            
                           ))
                            
                             ),
                   
                  
                  ## LOCATION TAB: 
                  
                  
                  navbarMenu("Check-In Locations", icon = icon("location-arrow"),
                              tabPanel("Top-20 Check-In Locations NYC", icon = icon("trophy"),
                                       fluidRow(
                                         column(4,
                                                h3("Mi Casa.."),
                                                p("Twitter users are more likely to check-in at their private home around afternoon, closely followed by Bars. An interesting aspect is that the Office is 
                                                    placed at the 3rd place, where the majority of Twitter users check-in in the morning. The question raised before, is Twitter check-ins annoying in the newsfeed? 
                                                    It seems like Twitter users tend to check-in at their private home and at the office, which might to some extent explain why non-popular people check-in more than 
                                                    popular people. Boring check-in places such as private home and at the office could potentially cost you your lovely followers! "),
                                                h4("Manhattans own Bermuda Traingle"),
                                                p("Zooming in at Manhattan revealed that people tend to be more likely to check-in around the lower part of Manhattan. More precisely, around Hells-kitchen, Time-square, 
                                                  and Rockefeller, areas constituting of a lot of offices, bars, and coffee shops.")

              
                                                 
                                                ),
                                       
                                         column(8, 
                                                h2(""),
                                         plotOutput("stacked")))
                                       
                              
                                       
                                       ),
                              
                              tabPanel("Gender differences", icon = icon("venus-mars"),
                                       fluidRow(
                                         column(6,
                                                h2("Females go to the coffee shop..."),
                                                img(src="Females20.png", width="600", height="400")
                                             
                                                ),
                                         
                                         column(6,
                                                h2("While males go to the bar..."),
                                         img(src="Males20.png", width="600", height="400")))
                                       ),
                             
                             tabPanel("Popularity", icon = icon("fire"),
                                      fluidRow(
                                        column(6,
                                               h2("Non-popular"),
                                               img(src="Non-popular.png", width="600", height="400")
                                               
                                        ),
                                        
                                        column(6,
                                               h2("Popular"),
                                               img(src="Popular.png", width="600", height="400")))
                              
                              
                              
                              )),
                   
                   
                   
                   navbarMenu("More", icon = icon("info-circle"),
                              tabPanel("Bias",
                                       sidebarPanel(h6("Caution"),
                                          p("Bear in mind, the following points when going through the graphs.
                                              
                                            1.The dataset should be considered as somewhat imbalanced.
                                            

                                            2.The dataset favors men.

                                            ")),
                                       mainPanel())
                              
                                    
                              )
                                       
                                       
                               
                                
                   
                   
                   
))