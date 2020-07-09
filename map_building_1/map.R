# read libraries
library(tidyverse)
library(rnaturalearth)
library(sf)
library(raster)
library(ggrepel)
library(showtext)
font_add_google(
  "Lato",
  regular.wt = 300,
  bold.wt = 700)

# grab natural earth polygon data
if(!exists("land")){
  land <- ne_download(
    scale = 50,
    type = "land",
    category = "physical",
    returnclass = "sf")
  countries <- ne_countries(
    returnclass = "sf",
    scale = 50)
}

theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text(family = "Lato", color = "#22211d"),
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "lightblue", color = NA),
      panel.background = element_rect(fill = "lightblue", color = NA),
      legend.background = element_rect(fill = "#ffffff", color = NA),
      strip.background=element_blank(),
      plot.margin = margin(0,0,0,0,"cm"),
      panel.border = element_blank(),
      ...
    )
}

# create dataframe with locations
df <- data.frame(
  site = c("A", "B"),
  lat = c(30, 40),
  lon = c(0, 0)
)

# read in the land cover data
lc <- raster("modis_land_cover.tif")

# select only "tree" areas (classes 1 - 9)
# and convert to binary (1 == tree)
lc <- (lc > 0  & lc < 9)

# reassign the name of the variable "lc"
# see below
names(lc) <- "lc"

# convert from matrix to long format
# 1 row per location
lc <- lc %>%
  rasterToPoints %>%
  as.data.frame() %>%
  filter(lc != 0) # only retain pixels with a value

#---- plotting outline -----

# setup the ggplot
p <- ggplot() +

  # first layer is the land mass outline
  # as a grey border (fancy)
  geom_sf(data = land,
          fill = NA,
          color = "grey50",
          fill = "#dfdfdf",
          lwd = 1) +

  # crop the whole thing to size
  coord_sf(xlim = c(-30, 50),
           ylim = c(20, 70))

ggsave("output/01.png", width = 5, height = 5)

p <- p +

  # second layer are the countries
  # with a white outline and and a
  # grey fill
  geom_sf(data = countries,
          color = "white",
          fill = "#dfdfdf",
          size = 0.2) +

  # crop the whole thing to size
  coord_sf(xlim = c(-30, 50),
           ylim = c(20, 70))

ggsave("output/02.png", width = 5, height = 5)

p <- p +

  # then add the tree pixels
  # as tiles in green
  geom_tile(data = lc,
            aes(x = x,
                y = y),
            col = "darkolivegreen4") +

  # crop the whole thing to size
  coord_sf(xlim = c(-30, 50),
           ylim = c(20, 70))

ggsave("output/03.png", width = 5, height = 5)

p <- p +
  # overlay the country borders
  # to cover the tree pixels
  # fill = NA to not overplot
  geom_sf(data = countries,
          color = "white",
          fill = NA,
          size = 0.2) +

 # crop the whole thing to size
 coord_sf(xlim = c(-30, 50),
          ylim = c(20, 70))


ggsave("output/04.png", width = 5, height = 5)

p <- p +

  # add the locations of the sites
  # as a point
  geom_point(data = df,
             aes(lon, lat),
             col = "grey20") +

  # use ggrepel to add fancy
  # labels nudged to a
  # longitude of -25
  geom_text_repel(
    data = df,
    aes(lon,
        lat,
        label = site),
    nudge_x      = -25 - df$lon,
    direction    = "y",
    hjust        = 0,
    segment.size = 0.2,
    seed = 1 # ensures the placing is consistent between renders
  ) +

  # crop the whole thing to size
  coord_sf(xlim = c(-30, 50),
           ylim = c(20, 70))

ggsave("output/05.png", width = 5, height = 5)

p <- p +

  # add labels here if needed
  labs(x = NULL,
       y = NULL,
       title = "",
       subtitle = "",
       caption = "") +

  # crop the whole thing to size
  coord_sf(xlim = c(-30, 50),
           ylim = c(20, 70))

ggsave("output/06.png", width = 5, height = 5)

p <- p +

  # apply the map theme as created above
  theme_map()

# save the final plot
ggsave("output/07.png", width = 5, height = 5)

# you can animate the plot using imagemagick and the following command:
# convert -delay 100 -loop 0 *.png map.gif


