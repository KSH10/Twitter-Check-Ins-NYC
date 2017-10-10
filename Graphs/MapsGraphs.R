####GRPAHS AND MAPS######
library(leaflet)
library(maps)
library(dplyr)
library(leaflet.extras)
library(plotly)
library(ggmap)

##Making the data ready for maps and graphs###

setwd("~/R")

setwd("~/R/Twitter Check-in")

#Import the processed data 
nyc_p <- read.csv("nyc_final.csv",
                  stringsAsFactors = FALSE)


str(nyc_p)

#Convert
##First I need to change my "danish time setting"

Sys.getlocale()
Sys.setlocale("LC_TIME", "C")

#CONVERTING datetime to POSitX
nyc_p$date = as.POSIXct(nyc_p$date, "%Y-%m-%d", tz="US/Eastern")
class(nyc_p$date)

#Adding Year_month variable
nyc_p$yr_month <- format(as.Date(nyc_p$date), "%Y-%m")


##Converting to Rda
setwd('~/R/ShinyTest/ShinyPlotly/Plotly')
str(nyc_p)

save(nyc_p, file = "nycfinal1.Rda")


####MAPS#####

#The interactive is created directly in the server through ploty, while the map is created via mapbox

##1.0

###Stacked BarChart for the map###
popular <- nyc_p %>%
  group_by(., popularity, sex) %>%
  summarise(., checkin = n())

plot_ly(data = popular, x = ~popularity, y = ~checkin,
        type = "bar",
        name = ~sex, color = ~sex) %>%
  layout(yaxis = list(title = 'Count'), barmode = 'stack')

##2.0
##HEATMAP##

ggmap(get_map("manhattan", zoom=13, maptype="terrain")) + #Types of maps: https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
  geom_density2d(data = nyc_p, 
                 aes(x = longitude, y = latitude), size = 0.3) + 
  stat_density2d(data = nyc_p, aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = "polygon") + 
  scale_fill_gradient(low = "green", high = "red") + scale_alpha(range = c(0, 0.3), guide = FALSE)



##3.0
#TREND PLOTS
time <- nyc_p %>%
  group_by(., yr_month) %>%
  summarise(., count = n())

#Reorder & converting month into a factor. Ordered according to the data gathering period April -> February
# time$month <- factor(time$month,
#                      levels = c("April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February"))

class(time$month)

#PLOTLY
plot_ly(time, x = ~yr_month, y = ~count, name = 'High 2014', type = 'scatter', mode = 'lines+markers')



#Trend - GENERAL DEVELOPMENT OF CHECKINS GGPLOT
save(time, file = "development.Rda")

x  <- nyc_p %>%
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



#Trend for SEX
time_sex <- nyc_p %>%
  group_by(., yr_month, sex) %>%
  summarise(., count = n())



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


#Trend for popular versus non-popular
time_popular <- nyc_p %>%
  group_by(., yr_month, popularity) %>%
  summarise(., count = n()) %>%
  filter(., popularity != "NA")

class(time_popular$month)

nyc_p %>%
  group_by(., yr_month, popularity) %>%
  summarise(., count = n()) %>%
  filter(., popularity != "NA") %>%
  ggplot(aes(x = yr_month, y = count, group = popularity, color = popularity)) +
  geom_point(size = 3.0)+
  geom_line(size = 2)+
  ggtitle("Twitter Checkin popular versus non-popular")+
  theme_solarized() +
  theme(plot.title = element_text(size=20, 
                                  face="bold",
                                  hjust = 0.5))


#####GRPAHS########


##4.0
###STACKED BAR CHART - WHERE ARE PEOPLE CHECKING-IN####
nyc_venues <- nyc_p %>%
  group_by(venuecategory, timeofday) %>%
  summarise(count = n()) %>%
  arrange(desc(count))
  
places_filtered <- nyc_p %>%
  group_by(venuecategory) %>%
  summarise(count=n()) %>%
  arrange(desc(count)) %>%
  top_n(20)

filtered = semi_join(nyc_venues, places_filtered, by = 'venuecategory')

##Creating timeofday to factor in order to order the variable
class(filtered$timeofday)

#Ordered Levels
filtered$timeofday <- factor(filtered$timeofday,
                             levels = c("Morning", "Midday", "Afternoon", "Evening", "Night" ))

ggplot(data = filtered, aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  coord_flip()+
  labs(title="NYC top 20 check-in places ", y = "Number of checkins", x = "Places")+
  theme_solarized() +
  scale_fill_brewer(palette='Set1')

#Ready for shiny
setwd('~/R/ShinyTest/ShinyPlotly/Plotly')

save(filtered, file = "filtered.Rda")



###STACKED BAR CHART - FEMALE VERSUS MALE : WHERE ARE PEOPLE CHECKING-IN####
nyc_venues_sex <- nyc_p %>%
  group_by(venuecategory, timeofday, sex) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

places_filtered <- nyc_p %>%
  group_by(venuecategory) %>%
  summarise(count=n()) %>%
  arrange(desc(count)) %>%
  top_n(20)

filtered_sex = semi_join(nyc_venues_sex, places_filtered, by = 'venuecategory')

##Creating timeofday to factor in order to order the variable
class(filtered$timeofday)

#Ordered Levels
filtered_sex$timeofday <- factor(filtered_sex$timeofday,
                             levels = c("Morning", "Midday", "Afternoon", "Evening", "Night"))


#MALE TOP 20 checkin palces
filtered_sex_male <- filtered_sex %>%
  filter(., sex == "male")

save(filtered_sex_male, file = "sexmale.Rda")

ggplot(data = filtered_sex_male, aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  coord_flip()+
  ggtitle("Males Top 20 Twitter Check-in places NYC") +
  labs(y = "Number of checkins", x = "Places")+
  theme_solarized() +
  scale_fill_brewer(palette='Set1') +
  theme(plot.title = element_text(size=20, 
                                  face="bold",
                                  hjust = 0.7))


#FEMALE TOP 20 checkin places
filtered_sex_female <- filtered_sex %>%
  filter(., sex == "female")

ggplot(data = filtered_sex_female, aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  coord_flip()+
  ggtitle("Females Top 20 Twitter Check-in places NYC") +
  labs(y = "Number of checkins", x = "Places")+
  theme_solarized() +
  scale_fill_brewer(palette='Set1') +
  theme(plot.title = element_text(size=20, 
                                  face="bold",
                                  hjust = 0.7))


####POPULAR VERSUS NON-POPULAR
nyc_venues_popularity <- nyc_p %>%
  group_by(venuecategory, timeofday, popularity) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

places_filtered <- nyc_p %>%
  group_by(venuecategory) %>%
  summarise(count=n()) %>%
  arrange(desc(count)) %>%
  top_n(20)

filtered_popularity = semi_join(nyc_venues_popularity, places_filtered, by = 'venuecategory')

filtered_popularity$timeofday <- factor(filtered_popularity$timeofday,
                                 levels = c("Morning", "Midday", "Afternoon", "Evening", "Night"))

#POPULAR TOP 20 checkin places
filtered_popularity_popular <- filtered_popularity %>%
  filter(.,  popularity == "popular") %>%
  filter(., popularity != "NA")




ggplot(data = filtered_popularity_popular, aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  coord_flip()+
  ggtitle("Popular: Top 20 Twitter Check-in places NYC") +
  labs(y = "Number of checkins", x = "Places")+
  theme_solarized() +
  scale_fill_brewer(palette='Set1') +
  theme(plot.title = element_text(size=20, 
                                  face="bold",
                                  hjust = 0.5))


# NON-POPULAR
filtered_popularity_nonpopular <- filtered_popularity %>%
  filter(.,  popularity == "non-popular") %>%
  filter(., popularity != "NA")


ggplot(data = filtered_popularity_nonpopular, aes(x=reorder(venuecategory, count), y=count, fill=timeofday)) + 
  geom_bar(stat = "identity", position = position_stack(reverse = TRUE)) +
  coord_flip()+
  ggtitle("Non-popular: Top 20 Twitter Check-in places NYC") +
  labs(y = "Number of checkins", x = "Places")+
  theme_solarized() +
  scale_fill_brewer(palette='Set1') +
  theme(plot.title = element_text(size=20, 
                                  face="bold",
                                  hjust = 0.5))




###BARCHART####
dailychecin <- nyc_p %>%
  group_by(., dayofweek) %>%
  summarise(., checkin = n())

dailychecin$dayofweek <- factor(dailychecin$dayofweek,
                                levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

#Histogram
plot_ly(data = time, x = ~month, y = ~count,
        marker = list(size = 10,
                      color = 'rgba(255, 182, 193, .9)',
                      line = list(color = 'rgba(152, 0, 0, .8)',
                                  width = 2))) %>%
  layout(title = 'Check-in over time',
         yaxis = list(zeroline = FALSE),
         xaxis = list(zeroline = FALSE))
