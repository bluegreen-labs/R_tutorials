# load libraries
library(ecmwfr)

# the request to be made to grab the
# required precip, total monthly precip
# and the fraction of large events
request <- list(
  format = "netcdf",
  product_type = "monthly_averaged_reanalysis",
  variable = c("2m_temperature",
               "downward_uv_radiation_at_the_surface"),
  time = "00:00",
  month = c("01", "02", "03", "04",
            "05", "06", "07", "08",
            "09", "10", "11", "12"),
  year = "2020",
  dataset_short_name = "reanalysis-era5-single-levels-monthly-means",
  target = "uv_temp.nc"
)

# requires preset credentials using
# wf_set_key(), see ecmwfr docs
wf_request(
  request = request,
  user = "2088",
  path = "data/"
  )

