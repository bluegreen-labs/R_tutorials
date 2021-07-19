# Mock bivariate map example

# load tidyverse
library(tidyverse)
library(raster)
library(rnaturalearth)
library(sf)
library(patchwork)

# custom fonts
library(showtext)
font_add_google("Prata", regular.wt = 400)
showtext_auto()

# set robinson projection
robinson <- CRS("+proj=robin +over")

# read in raster data

# max monthly UV data (scaled by seconds in a day
# and referenced by a location in Belgium
# assuming UV max values of around 10 in
# this region)
u <- brick("data/uv_temp.nc", varname = "uvb")
u <- (max(u/(24*60*60), na.rm = TRUE)/ 32) * 10
u <- rotate(u)

# max yearly monthly temperature converted to C
# from K
t <- brick("data/uv_temp.nc", varname = "t2m")
t <- max(t) - 273.15
t <- rotate(t)

# download countries 
countries <- ne_countries(scale = 50, returnclass = c("sf"))

# create a bounding box for the robinson projection
# we'll use this as "trim" to remove jagged edges at
# end of the map (due to the curved nature of the
# robinson projection)
bb <- sf::st_union(sf::st_make_grid(
  st_bbox(c(xmin = -180,
            xmax = 180,
            ymax = 90,
            ymin = -90), crs = st_crs(4326)),
  n = 100))
bb_robinson <- st_transform(bb, as.character(robinson))

# transform the coastline to robinson
countries_robinson <- st_transform(countries, robinson)

# convert gridded raster dato dataframe
u_df <- u %>%
  projectRaster(., res=50000, crs = robinson) %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "uv"))

t_df <- t %>%
  projectRaster(., res=50000, crs = robinson) %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "temp"))

# reclassify data using threshold values
# so we get 3 classes for each layer
u_df <- u_df %>%
  mutate(
    val = ifelse(uv <= 10, "1",
                 ifelse(uv >= 12, "3",
                        "2"))
  )

t_df <- t_df %>%
  mutate(
    val = ifelse(temp <= 10, "1",
                 ifelse(temp >= 28, "3",
                        "2"))
  )

# bind data by location and group
# by the value (index) created above
df <- left_join(t_df, u_df, by = c("x","y")) %>%
  mutate(
    group = paste(val.y, val.x, sep = " - ")
  ) %>%
  dplyr::select(-c(val.x, val.y))

# create a bivariate legend with indices
# matching those created above
legend_3 <- tibble(
  "3 - 3" = "#3F2949", # high UV, high temp
  "2 - 3" = "#435786",
  "1 - 3" = "#4885C1", # low UV, high temp
  "3 - 2" = "#77324C",
  "2 - 2" = "#806A8A", # medium UV, medium temp
  "1 - 2" = "#89A1C8",
  "3 - 1" = "#AE3A4E", # high UV, low temp
  "2 - 1" = "#BC7C8F",
  "1 - 1" = "#CABED0" # low UV, low temp
) %>%
  gather("group", "fill")

# match the group constructed
# above with the colour scheme
# with 3 categories this is the
# plotting dataframe
df <- left_join(df, legend_3)

# create the main map
p1 <- ggplot()+
  geom_raster(
    data = df,
    aes(
      x=x,
      y=y,
      fill=fill
    ),
    interpolate = TRUE
    ) +
  scale_fill_identity() +
  geom_sf(data=countries_robinson,
          colour='grey25',
          linetype='solid',
          fill= NA,
          size=0.3) +
  geom_sf(data=bb_robinson,
          colour='white',
          linetype='solid',
          fill = NA,
          size=0.7) +
  labs(
    title = "Liquids: drink it, or rub it!",
    subtitle = "Do you always need water & sunscreen?",
    caption = "
Data: Copernicus Climate Data Store - 2020
Temperature thresholds: low < 10C < mid < 28C < high
Max seasonal UV Thresholds: normal < 10 < mid < 12 < high
"
  ) +
  theme_void() +
  theme(legend.position = 'none',
        plot.subtitle = element_text(
          color = "grey30",
          size = 40,
          hjust = 0.1),
        plot.title = element_text(
          family = "Prata",
          color = "grey30",
          size = 70,
          hjust = 0.1),
        plot.caption = element_text(
          color = "grey30",
          size = 25,
          lineheight = 0.3),
        plot.margin = margin(r = 10)
        )

# create the legend
p2 <- legend_3 %>%
  separate(group,
           into = c("uv", "temp"),
           sep = " - ") %>%
  mutate(temp = as.integer(temp),
         uv = as.integer(uv)) %>%
  ggplot() +
  geom_tile(mapping = aes(
    x = uv,
    y = temp,
    fill = fill)) +
  scale_fill_identity() +
  labs(x = "sunscreen →",
       y = "hydrate →") +
  theme_void() +
  theme(
    axis.title = element_text(
      size = 25,
    ),
    axis.title.y = element_text(angle = 90)) +
  coord_fixed()

# create a layout to plot both
# the main figure and the legend
layout <- c(
  area(t = 1, l = 1, b = 7, r = 7),
  area(t = 1, l = 6, b = 1, r = 7)
)

# create final layout
p <- p1 + p2 + 
  plot_layout(design = layout)

# save the plot
ggsave("drink_or_rub.png", width = 11)
