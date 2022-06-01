# read in libraries
library(tidyverse)
library(raster)
library(metR)
library(rnaturalearth)

theme_map <- function(...) {
  theme_minimal() +
    theme(
      legend.key = element_rect(fill = "white", size = 1),
      legend.key.size = unit(0.5, "cm"),
      legend.key.width = unit(2.5, "cm"),
      legend.margin = margin(10, 10, 10, 10),
      legend.text = element_text(
        size = 10,
        angle = 45,
        vjust = 1,
        hjust = 1),
      legend.position = "bottom",
      axis.line = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "#ffffff", color = NA),
      panel.background = element_rect(fill = "#ffffff", color = NA),
      legend.background = element_rect(fill = "#ffffff", color = NA),
      text = element_text(family = "Montserrat", color = "grey30", size=12),
      panel.border = element_blank(),
      plot.margin = margin(5, 0, 5, 0),
      axis.title.y = element_text(face = "bold", vjust = 10),
      axis.title.x = element_text(face = "bold", vjust = -2),
      panel.spacing = unit(1, "lines"),
      ...
    )
}

# coastline sf object
land <- ne_coastline(
  scale = 50,
  returnclass = "sf")

# convert pressure
pressure <- raster::raster(
  "data/wind.nc",
  varname = "msl"
  ) %>%
  rasterToPoints() %>%
  as.data.frame() %>%
  rename(
    'lat' = 'y',
    'lon' = 'x',
    'pressure' = 'Mean.sea.level.pressure'
  ) %>%
  pivot_longer(
    cols = "pressure",
    names_to = "layer",
    values_to = "pressure"
  ) %>%
  mutate(
    pressure = pressure / 100
  )

# convert wind
u <- raster::raster("data/wind.nc",
                   varname = "u10") %>%
  rasterToPoints() %>%
  as.data.frame() %>%
  rename(
    'lat' = 'y',
    'lon' = 'x',
    'u' = starts_with("X10")
  ) %>%
  pivot_longer(
    cols = "u",
    names_to = "layer",
    values_to = "u"
  ) %>%
  dplyr::select(-layer)

v <- raster::raster(
  "data/wind.nc",
  varname = "v10") %>%
  rasterToPoints() %>%
  as.data.frame() %>%
  rename(
    'lat' = 'y',
    'lon' = 'x',
    'v' = starts_with("X10")
  ) %>%
  pivot_longer(
    cols = "v",
    names_to = "layer",
    values_to = "v"
  ) %>%
  dplyr::select(-layer)

wind <- left_join(u, v)

p <- ggplot() +
  geom_contour_fill(
    data = pressure,
    aes(
      lon,
      lat,
      z = pressure,
      fill = stat(level)
    ),
    breaks = MakeBreaks(3)
  ) +
  geom_sf(data = land,
          color = "white",
          fill = NA,
          size = 1.2
  ) +
  geom_sf(data = land,
          color = "grey50",
          fill = NA,
          size = 0.4
  ) +
  metR::geom_streamline(
    data = wind,
    aes(x = lon,
        y = lat,
        dx = u,
        dy = v,
        alpha = ..step..
    ),
    color = "grey",
    size = 0.4,
    L = 2,
    res = 2,
    n = 30,
    arrow = NULL,
    lineend = "round",
    inherit.aes = FALSE) +
  scale_alpha(guide = "none") +
  scale_fill_divergent_discretised(
    high = "#7f3b08",
    mid = "#f7f7f7",
    low = "#2d004b",
    name = "mean sea leavel pressure (hPa) \n \n ",
    midpoint = 984
  ) +
  labs(
    title = "Hurricane Katrina",
    subtitle = "peak intensity at August 28, 2005",
    x = "",
    y = ""
  ) +
  coord_sf(xlim = c(-95, -75),
           ylim = c(36, 23)) +
  theme_map()

print(p)
ggsave("map.png", height = 8, width = 9)
