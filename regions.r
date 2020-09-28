library("maps")
library("RColorBrewer")
library("scales")

map_world <- map_data("world")
map_world <- map_world %>%
  mutate(region = recode(region, `USA` = "United States")) %>%
  mutate(region = recode(region, `UK` = "United Kingdom")) %>%
  mutate(region = recode(region, `Ivory Coast` = "Cote d`Ivoire"))

f_countries <- f_countries %>%
  mutate(country = recode(country, `Congo, Democratic Republic of` = "Democratic Republic of the Congo")) %>%
  mutate(country = recode(country, `Congo, Republic of` = "Republic of Congo"))

  

world_choro <- left_join(map_world, f_countries, by = c("region" = "country"))

world_choro %>%
  mutate(net_donations = net_donations / 1e9) %>%
  ggplot(aes(long, lat)) + 
    geom_polygon(aes(group = group, fill = net_donations)) +
    coord_quickmap() +
    # scale_fill_viridis_b()
    # scale_fill_continuous()
    scale_fill_gradient2()


world_choro %>%
  mutate(net_donations = net_donations / 1e9) %>%
  ggplot(aes(long, lat)) + 
  geom_polygon(aes(group = group, fill = net_donations)) +
  coord_quickmap() +
  scale_fill_distiller(name = "Net Donations", palette = "RdYlBu", direction = 1, limits = c(-30, 30))
  
# histogram of net donations
f_countries %>%
  ggplot(aes(x = net_donations / 1e9)) +
  geom_histogram(binwidth = 1)

# histogram colored by the RdYlBu scale
f_countries %>%
  ggplot(aes(x=net_donations / 1e9)) +
  geom_histogram( aes(fill = ..x..), binwidth = 1) +
  scale_fill_distiller(name = "Net Donations", palette = "RdYlBu", direction = 1, limits = c(-30, 30)) +
  xlim(-30, 30) +
  xlab("Net Donations (Billions, USD)") +
  theme(legend.position = "bottom", legend.title = element_blank()) +
  theme(legend.key.width=unit(50, "points"))


# gradient colors
world_choro %>%
  mutate(net_donations = net_donations / 1e9) %>%
  ggplot(aes(long, lat)) + 
  geom_polygon(aes(group = group, fill = net_donations)) +
  coord_quickmap() +
  scale_fill_gradient2(name = "Net Donations", low = "red", mid = "white", high = "blue")

f_countries %>%
  ggplot(aes(x=net_donations / 1e9)) +
  geom_histogram( aes(fill = ..x..), binwidth = 1) +
  scale_fill_gradient2(name = "Net Donations", low = "red", high = "blue") +
  xlab("Net Donations") +
  xlim(-30, 30)


# Red - White - Blue
log_mid = log(1 - min(f_countries$net_donations/1e9))

f_countries %>%
  ggplot(aes(x=log(net_donations/1e9 + 1 - min(net_donations/1e9)))) +
  geom_histogram( aes(fill = ..x..), binwidth = .235) +
  xlab("Log Transform of Net Donations") +
  xlim(0, 2*log_mid) +
  scale_fill_gradient2(low = "red", high = "blue", midpoint = log_mid) +
  theme(legend.position = "bottom", 
        legend.title = element_blank(), 
        legend.text = element_blank()) +
  theme(legend.key.width=unit(90, "points"))


log_mid = log(10 - min(f_countries$net_donations/1e9))
min_net_donations = min(f_countries$net_donations/1e9)

world_choro %>%
  mutate(log_net_donations = log(net_donations/1e9 + 10 - min_net_donations)) %>%
  ggplot(aes(long, lat)) + 
  geom_polygon(aes(group = group, fill = log_net_donations)) +
  coord_quickmap() +
  scale_fill_gradient2(name = "Net Donations", 
                       low = "red", 
                       mid = "white", 
                       high = "blue", 
                       midpoint = log_mid) +
  theme(legend.text = element_blank())


world_choro %>%
  mutate(net_donations = net_donations / 1e9) %>%
  ggplot(aes(long, lat)) + 
  geom_polygon(aes(group = group, fill = net_donations)) +
  coord_quickmap() +
  scale_fill_gradientn(name = "Net Donations", 
                       colors = c("red", "white", "blue"),
                       breaks = c(-10, 0, 30), 
                       limits = c(-30, 30))

max = max(world_choro$net_donations, na.rm = TRUE)
min = min(world_choro$net_donations, na.rm = TRUE)
world_choro %>%
  mutate(metric = ifelse(net_donations > 0, 
                         net_donations/max, 
                         -net_donations/min)) %>%
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = metric)) +
  coord_map("azequidistant", orientation = c(0, 0, 0)) +
  scale_fill_gradient2("Net Donations", 
                       low = "#D73027",
                       mid = "#FFFFFF",
                       high = "#4575B4")

library(ggplot2)
library(ggalt)
library(ggthemes)
library(sf)

world_choro %>%
  mutate(metric = ifelse(net_donations > 0, 
                         net_donations/max, 
                         -net_donations/min)) %>%
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = metric)) +
  coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs") +
  scale_fill_gradient2("Net Donations", 
                       low = "#D73027",
                       mid = "#FFFFFF",
                       high = "#4575B4")


# states <- map_data("state")
# arrests <- USArrests
# names(arrests) <- tolower(names(arrests))
# arrests$region <- tolower(rownames(USArrests))
# 
# choro <- merge(states, arrests, sort = FALSE, by = "region")
# choro <- choro[order(choro$order), ]
# ggplot(choro, aes(long, lat)) +
#   geom_polygon(aes(group = group, fill = assault)) +
#   coord_map("albers",  at0 = 45.5, lat1 = 29.5)
