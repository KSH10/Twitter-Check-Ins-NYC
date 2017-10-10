library(data.table)
library(plotly)
library(ggplot2)
library(ggthemes)


#setwd('~/R/ShinyTest/ShinyPlotly/Plotly')

load("sexmale.Rda") #dataset for stackedbart MALE
load("development.Rda")
load("nycfinal1.Rda") #dataset for map
load("filtered.Rda") #dataset for stackedbarchart


#Map for plotly created via mapbox:
Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1Ijoia2VubmV0aGhhbnNlbiIsImEiOiJjajhkdWY2azMwdW5sMndva3UxcXBkY3U3In0.4bOOyyoh3QjocKrHhWQtMg')


 