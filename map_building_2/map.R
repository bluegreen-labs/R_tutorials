# Dealing with raster resolution problems
# when mixing raster and vector data.

# load libraries
library(raster)
library(tidyverse)
library(rnaturalearth)

# grab country outlines / ocean areas as sf object
countries <- ne_countries(returnclass = "sf", scale = 50)

# create a fake coarse grid raster
# with a "EU" extent
r <- matrix(rnorm(100),10,10)
r <- raster(r)
extent(r) <- c(-20,20,30,70)

# convert raster to dataframe
# for ggplot2 plotting
r_df <- r %>%
  rasterToPoints %>%
  as.data.frame() %>%
  filter(layer!=0)

p <- ggplot() +
  geom_raster(data = r_df,
              aes(x = x,
                  y = y,
                  fill = layer)) +
  scale_fill_continuous() +
  
  geom_sf(data = countries,
          color = "white",
          fill = NA,
          size = 0.2) +
  
  # crop
  coord_sf(xlim = c(-20, 20),
           ylim = c(30, 70))

ggsave("output/01.png", width = 5, height = 5)

# mask these values using the countries
# and convert to dataframe for ggplot2
# plotting
r_m <- mask(r, countries)
r_m_df <- r_m %>%
  rasterToPoints %>%
  as.data.frame() %>%
  filter(layer!=0)


p <- ggplot() +
  geom_raster(data = r_m_df,
              aes(x = x,
                  y = y,
                  fill = layer)) +
  scale_fill_continuous() +
  
  geom_sf(data = countries,
          color = "white",
          fill = NA,
          size = 0.2) +
  
  # crop
  coord_sf(xlim = c(-20, 20),
           ylim = c(30, 70))

ggsave("output/02.png", width = 5, height = 5)

# THE COVER UP
# download ocean outlines
ocean <- ne_download(
  scale = 50,
  type = "ocean",
  category = "physical",
  returnclass = "sf")

# overplot the undesired coarse raster edges
p <- ggplot() +
  geom_raster(data = r_df,
              aes(x = x,
                  y = y,
                  fill = layer)) +
  scale_fill_continuous() +
  
  geom_sf(data = ocean,
          color = NA,
          fill = "white",
          size = 0.2) +
  
  geom_sf(data = countries,
          color = "white",
          fill = NA,
          size = 0.2) +
  
  # crop the whole thing to size
  coord_sf(xlim = c(-20, 20),
           ylim = c(30, 70))

ggsave("output/03.png", width = 5, height = 5)

# UPSAMPLE 100x and mask, then
# convert to data frame
r_u <- disaggregate(r, 100)
r_u <- mask(r_u, countries)
r_u_df <- r_u %>%
  rasterToPoints %>%
  as.data.frame() %>%
  filter(layer!=0)

p <- ggplot() +
  geom_raster(data = r1_df,
              aes(x = x,
                  y = y,
                  fill = layer)) +
  scale_fill_continuous() +
  
  geom_sf(data = countries,
          color = "white",
          fill = NA,
          size = 0.2) +
  
  # crop the whole thing to size
  coord_sf(xlim = c(-20, 20),
           ylim = c(30, 70))

ggsave("output/04.png", width = 5, height = 5)





