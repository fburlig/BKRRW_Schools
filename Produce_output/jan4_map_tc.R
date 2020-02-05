######################################################################
##### CODE TO PLOT TREATMENT VS. CONTROL SCHOOLS
##### 
######################################################################


############################ SETUP ####################################
rm(list=ls())

### DIRECTORY PATHS
# main directory
setwd("T:/Projects/Schools")

# main data directory
dataDir <- paste(getwd(), "/Data", sep = "")
# spatial data directory
spatialDir <- paste(dataDir, "/Other data/utility Map", sep = "")

#figure directory
figDir <- paste(getwd(), "/Results/Final", sep = "")

### PACKAGES
library(GISTools)
library(readr)
library(dplyr)
library(ggplot2)
library(rgeos)
library(rgdal)
library(maptools)
library(broom)
library(haven)


### FUNCTIONS
#fxn to convert data to tbl_df's in one step
as.tbl_df <- function(data) {
  dataset <- as.data.frame(data) %>%
    tbl_df()
}

mapToDF <- function(shapefile) {
  # first assign an identifier to the main dataset
  shapefile@data$id <- rownames(shapefile@data)
  # now ``tidy'' our data to convert it into 
  #  dataframe that's usable by ggplot2
  #  the region command keeps polygons together
  mapDF <- tidy(shapefile) %>% 
    # and this data onto the information attached to the shapefile
    left_join(., shapefile@data, by = "id") %>%
    as.tbl_df()
  return(mapDF)
}

### GGPLOT2 SETUP

myThemeStuff <- theme(panel.background = element_rect(fill = NA),
                      panel.border = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text = element_blank(),
                      axis.title = element_blank(),
                      legend.key = element_blank())

# custom colors for graphing
myBlue <- rgb(0/255, 128/255, 255/255, 1)
myGray <- rgb(224/255, 224/255, 224/255, 1)

################################################################
### SPATIAL DATA
## load in the US states shapefile
states <- readOGR(dsn=spatialDir, layer = "cb_2015_us_state_5m")
stateDF <- mapToDF(states)

# keep only the California portion
caDF <- filter(stateDF, NAME == "California")

## load the utility map shapefile
utility <- readOGR(dsn=spatialDir, layer = "CA_Electric_Investor_Owned_Utilities_IOUs")
# re-project to be in lat-long
utility <- spTransform(utility, CRS(proj4string(states)))

utilityDF <- mapToDF(utility)


pgeDF <- filter(utilityDF, id == 3, piece == 1)


################################################################
### T VS. C DATA
schoolDF <- read_dta(paste(spatialDir, "/utility_map_fromstata.dta", sep = "")) %>%
  rename(lat = cde_lat, long = cde_long) %>% 
  mutate(lat = ifelse(lat < 36.25 & long > -118.6, NA, lat)) %>%
  mutate(lat = ifelse(lat > 40 & lat < 41 & long < -123 & long > -123.65, NA, lat)) %>%
  filter(is.na(lat) == 0) 
  

schoolDF_C <- filter(schoolDF, tc == 0) %>% mutate(tc_fac = 0)
schoolDF_T <- filter(schoolDF, tc == 1) %>% mutate(tc_fac = 1)

schoolDFUtilityPlot <- bind_rows(schoolDF_C, schoolDF_T) %>%
  mutate(tc_fac = factor(tc_fac, levels = c(0, 1), labels = c("Control", "Treatment")))

################################################################
### MAP


utilityMap_C <- ggplot() +
  geom_polygon(data = pgeDF, aes(x = long, y = lat, group = group),
               color = 'gray75', fill = 'NA') +
  geom_polygon(data = caDF, aes(x = long, y = lat, group = group),
               color = 'black', fill = 'NA') +
  geom_point(data = schoolDF_C, aes(x = long, y = lat),
             size = 1.5, color = 'gray70', shape = 19)  +
  #geom_point(data = schoolDF_T, aes(x = long, y = lat),
  #           size = 1.5, color = myBlue, shape = 21, alpha = 0.5)  +
  coord_fixed(ratio = 1.25) +
  guides(colour = guide_legend("Energy efficiency upgrades"),
         shape = guide_legend("Energy efficiency upgrades")) +
  myThemeStuff

utilityMap_C
figPath <- paste(figDir, "/utilitymap_conly.pdf", sep = "")
ggsave(figPath, device = "pdf", width = 8.5, height = 11)


utilityMap_T <- ggplot() +
  geom_polygon(data = pgeDF, aes(x = long, y = lat, group = group),
               color = 'gray75', fill = 'NA') +
  geom_polygon(data = caDF, aes(x = long, y = lat, group = group),
               color = 'black', fill = 'NA') +
  #geom_point(data = schoolDF_C, aes(x = long, y = lat),
  #           size = 1.5, color = 'gray70', shape = 19)  +
  geom_point(data = schoolDF_T, aes(x = long, y = lat),
             size = 1.5, color = myBlue, shape = 19)  +
  coord_fixed(ratio = 1.25) +
  guides(colour = guide_legend("Energy efficiency upgrades"),
         shape = guide_legend("Energy efficiency upgrades")) +
  myThemeStuff

utilityMap_T
figPath <- paste(figDir, "/utilitymap_tonly.pdf", sep = "")
ggsave(figPath, device = "pdf", width = 8.5, height = 11)

