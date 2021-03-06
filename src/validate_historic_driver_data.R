library(assertthat)
library(ncmeta)

validate_historic_driver_data <- function(var, fn, data_nc, hruids, time, time_fixed, n_hrus = 114958, n_days = 14975) {
  
  # 12783 days is ~ 35 years
  
  ##### Test: NetCDF dimensions and variables are as expected #####
  
  # Get a bit more detailed metadata
  meta_info <- nc_meta(fn)
  
  assert_that(meta_info$dimension$name[1] == "nhru")
  assert_that(meta_info$dimension$name[2] == "time")
  assert_that(meta_info$dimension$length[1] == n_hrus) # Expect all hruids
  assert_that(meta_info$dimension$length[2] == n_days) # Expect a specific number of days
  
  # Test unit for variable
  units_att_list <- nc_att(fn, var, "units")[["value"]]
  assert_that(unlist(units_att_list) == "inches") # Expect inches
  
  ##### Test: NetCDF hruids are in expected order and the expected data type #####
  assert_that(is.integer(hruids))
  assert_that(all(as.vector(hruids) == 1:n_hrus)) # need to make hruids a vector instead of matrix w 1 dim in order to test sameness
  
  ##### Test: NetCDF time is in expected order and expected data type #####
  assert_that(is.double(time))
  assert_that(length(time) == n_days) # Expect a specific number of days 
  
  ##### Test: NetCDF actual data is formatted as expected #####
  assert_that(is.double(data_nc))
  assert_that(nrow(data_nc) == n_hrus) 
  assert_that(ncol(data_nc) == n_days) 
  
  # General order of magnitude test
  # Max of total storage in all of historic data for all HRUs is ~5,000 mm
  # Considering 300 mm is about 1 ft of water
  # An absolute max for order of magnitude check of 10,000 mm seems appropriate
  assert_that(max(data_nc) < 10000)
  
  # The validation step for order of magnitude for the daily model output has this step
  # but it will send an email (NOT FAIL) if this condition is not met. For the purposes
  # of calculating the historic percentiles, we will have this step fail if it is not met. 
  # The historic percentile calculation is more hands on and people should investigate this
  # issue immediately before proceeding.
  
}

validate_historic_data_times_match <- function(date_list, vars) {
  for(i in head(seq_along(vars), -1)) {
    var1 <- vars[i]
    var2 <- vars[i+1]
    message(sprintf("Running test for times in %s == %s", var1, var2))
    assert_that(all(date_list[[var1]] == date_list[[var2]]))
  }
}
