# load libraries
library(ecmwfr)

# if using a file based key store
# uncomment (see ecmwfr documentation)
# options(keyring_backend="file")

request <- list(
  product_type = "reanalysis",
  format = "netcdf",
  variable = c(
    "10m_u_component_of_wind",
    "10m_v_component_of_wind",
    "mean_sea_level_pressure"),
  year = "2005",
  day = "28",
  month = "08",
  time = "12:00",
  area = c(38, -104, 20, -73),
  dataset_short_name = "reanalysis-era5-single-levels",
  target = "wind.nc"
)

# requires preset credentials using
# wf_set_key(), see ecmwfr docs
wf_request(
  request = request,
  user = "2088",
  path = "data/"
  )

