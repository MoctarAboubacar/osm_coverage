# the point of this project is to assess the coverage of OSM data 
# this will be done by building, for select type(s) of point(s), predictions as to the count of points in a given area

# ex. (this is just early thinking at this point, we could change it):
# we could predict the number of bus stops in municipalities in the country, using districts where we know we have relatively good data to train a spatial model.
# We would then apply that prediction to out of sample areas to predict counts. The difference between the expected count and the existing counts in OSM data (with some threshold for error applied) give an idea of if a particular area is undercovered or not.

# A basic approach we can replicate is here: https://towardsdatascience.com/identifying-gaps-in-openstreetmap-coverage-through-machine-learning-257545c04330
# although we may want to do something simpler and just try to predict counts per palika...not sure.

# below is just r-code to query bus stops and districts in Nepal, but we could maybe go for something that we could tag manually with a high-res satellite image if we needed to (like they did in the link above) --buildings maybe.

# applications: directing future OSM data collection | 


# clean slate
rm(list = ls())

# packages
require(tidyverse)
require(sf)
require(osmdata)
require(units)

# bounding box
m <- matrix(c(79, 26, 88.5, 30.5), ncol = 2, byrow = TRUE)
row.names(m) <- c("x", "y")
names(m) <- c("min", "max")

# Nepal- country
q.nepal <- m %>% 
  opq() %>% 
  add_osm_feature(key = 'name:en', value = 'Nepal') %>% 
  osmdata_sf()
nepal <- q.nepal$osm_multipolygons

# get districts
q.district <- m %>% 
  opq() %>% 
  add_osm_feature(key = 'admin_level', value = '6') %>% 
  osmdata_sf()
district <- q.district$osm_multipolygons

# bus stops
q.bus <- m %>% 
  opq() %>% 
  add_osm_feature("amenity", "bus_station") %>% 
  osmdata_sf()
bus <- q.bus$osm_points

# keep only districts and bus stops within Nepal
district <- st_intersection(x = district, y = nepal)
bus <- st_intersection(x = bus, y = nepal)