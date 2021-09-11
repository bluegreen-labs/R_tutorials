# load libraries
library("raster")
library("tidyverse")
library("rnaturalearth")
library("sf")
library("gganimate")
library("gifski")

# custom fonts
library(showtext)
font_add_google("Prata", regular.wt = 400)
showtext_auto()

# set coordinate systems
robinson <- CRS("+proj=robin +over")

# create a bounding box for the robinson projection
bb <- sf::st_union(sf::st_make_grid(
  st_bbox(c(xmin = -179.999,
            xmax = 179.999,
            ymax = 90,
            ymin = -1), crs = st_crs(4326)),
  n = 100))
bb_robinson <- st_transform(bb, as.character(robinson))

# download global coastline data from naturalearth
countries <- ne_countries(scale = 110, returnclass = c("sf"))

# clip countries to bounding box
# and transform
countries_robinson <- countries %>%
  st_buffer(0) %>%
  st_intersection(st_union(bb)) %>%
  st_transform(robinson)

# load the grid data using raster
g <- stack("data/carbon.nc")

# convert gridded raster data dataframe
g_df <- g %>%
  projectRaster(., res=50000, crs = robinson) %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", names(g))) %>%
  pivot_longer(cols = starts_with("X20"),
               names_to = "layer",
               values_to = "val") %>%
  mutate(layer = substr(layer, 2, 14)) %>%
  mutate(date = as.POSIXct(layer, "%Y.%m.%d.%H", tz = "UTC")
         )

# formulate graphing element
world_map <- ggplot() +
  theme_void() +
  geom_tile(
    data = g_df,
    aes(
      x = x,
      y = y,
      fill = log(val),
      group = date)) +
  scale_fill_viridis_c(
    option = "B"
  ) +
  geom_sf(data=countries_robinson,
          colour='white',
          linetype='solid',
          fill = NA,
          size=0.2) +
  geom_sf(data=bb_robinson,
          colour='white',
          linetype='solid',
          fill = NA,
          size= 1) +
  coord_sf(ylim = c(-17309.98, 8582690)) +
  theme(
    plot.title = element_text(
      family = "Prata",
      #color = "grey30",
      size = 50,
      hjust = 0.5),
    plot.subtitle = element_text(
      hjust = 0.5,
      size = 25),
    plot.caption = element_text(
      color = "grey50",
      size = 12,
      hjust = 0.9),
    legend.position = "none"
    ) +
  labs(
    title = "Fire season",
    subtitle = "",
    caption = "Data source: Copernicus ADS at {current_frame}") +
  transition_manual(date)

#animate the plot
gganimate::animate(world_map,
                   width = 1000,
                   height = 400,
                   renderer=gifski_renderer("map.gif"))
