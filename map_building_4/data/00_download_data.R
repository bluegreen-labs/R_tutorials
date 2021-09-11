options(keyring_backend="file")

# load libraries
library("ecmwfr")

request <- list(
  date = "2021-07-21/2021-07-21",
  type = "forecast",
  format = "netcdf_zip",
  variable = "black_carbon_aerosol_optical_depth_550nm",
  time = "00:00",
  leadtime_hour = as.character(1:120),
  area = c(90, -180, 0, 180),
  dataset_short_name = "cams-global-atmospheric-composition-forecasts",
  target = "download.zip"
)

# download the data (file location is returned)
file <- wf_request(request, 
                   user = "2161")

# unzip zip file (when multiples are called this will be zipped)
unzip(file, exdir = tempdir())
files <- list.files(tempdir(), "*.nc", full.names = TRUE)

# copy files to data
file.copy(files, "data/carbon.nc")
