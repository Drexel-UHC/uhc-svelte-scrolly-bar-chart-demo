#' This script will generate the simulated data

{ # Setup -------------------------------------------------------------------
  
  { # Dependencies ---------------------------------------------------------------
    library(tidyverse)
    library(geojsonio)  
    library(jsonlite)
  }
}
 

{ # Original Svelte-chart Data ---------------------------------------------------------------
  
  flat_data <- tibble(
    year = c(2017, 2017, 2017, 2017, 2018, 2018, 2018, 2018, 2019, 2019, 2019, 2019, 2020, 2020, 2020, 2020),
    value = c(320, 480, 640, 400, 640, 960, 640, 400, 1600, 1440, 960, 400, 3840, 1920, 960, 400),
    group = c('apples', 'bananas', 'cherries', 'dates', 'apples', 'bananas', 'cherries', 'dates', 'apples', 'bananas', 'cherries', 'dates', 'apples', 'bananas', 'cherries', 'dates')
  )
  
  grouped_data = flat_data %>% 
    pivot_wider(names_from = group, values_from = value)
  
  flat_data %>% write.csv("../public/data/fruits_flat_data.csv", row.names = F)
  
  grouped_data %>% write.csv("../public/data/fruits_grouped_data.csv",  row.names = F)
}




