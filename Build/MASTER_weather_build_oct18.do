************************************************
**** BUILD WEATHER DATA
************************************************

* -- geoonear (ssc install geonear)

**** STEP 1: GRAB SCHOOL LAT-LONGS FROM PGE
import excel "$dirpath_data_raw/PGE_Oct_2016/PGE School Meter Matching to UCB 20161017.xlsx", sheet("All_Match") firstrow clear
* use the pge coords if DOE didn't provide them
replace CDE_LAT = LATITUDE if CDE_LAT == ""
replace CDE_LON = LONGITUDE if CDE_LON == ""

replace CDE_LAT = LATITUDE if CDS_CODE == "23752186025118"
replace CDE_LON = LONGITUDE if CDS_CODE == "23752186025118"

replace CDE_LAT = LATITUDE if CDS_CODE == "23752182332724"
replace CDE_LON = LONGITUDE if CDS_CODE == "23752182332724"


* fix the schools for which the DOE puts them out of CA
keep CDS_CODE CDE_LAT CDE_LON
rename *, lower
destring *, replace
* in case there are conflicting lat/lons:
collapse(mean) cde_lat cde_lon, by(cds_code)
duplicates drop
save "$dirpath_data_temp/school_coords.dta", replace

**** STEP 2: MATCH SCHOOLS TO WEATHER STATIONS

** open the master weather station info dataset
use "$dirpath_data_weather/weather_data_info_FINAL.dta", clear
* create a numeric station id variable
egen stnid = group(stn_call)
save "$dirpath_data_temp/weather_data_for_geonear.dta", replace
** save identical datasets with their station id's named differently
* this is a pain, but we do it because it makes it easy to
* match one school with the closest 5 weather stations
rename stnid stnid1
rename stn_call stn_call1
save "$dirpath_data_temp/weather_data_for_geonear1.dta", replace
rename stnid1 stnid2
rename stn_call1 stn_call2
save "$dirpath_data_temp/weather_data_for_geonear2.dta", replace
rename stnid2 stnid3
rename stn_call2 stn_call3
save "$dirpath_data_temp/weather_data_for_geonear3.dta", replace
rename stnid3 stnid4
rename stn_call3 stn_call4
save "$dirpath_data_temp/weather_data_for_geonear4.dta", replace
rename stnid4 stnid5
rename stn_call4 stn_call5
save "$dirpath_data_temp/weather_data_for_geonear5.dta", replace

*** Actually do the distance match (using geonear)
* open the school coordinates data
use "$dirpath_data_temp/school_coords.dta", clear
* use geonear: take the school identifier and school coordinates and compare to the weather station ids and coordinates.
	* grab the closest 5 stations (nids are the ids of the weather station "neighbors").
geonear cds_code cde_lat cde_lon using "$dirpath_data_temp/weather_data_for_geonear.dta", n(stnid stn_lat stn_lon) ignoreself near(5)
rename nid1 stnid1
rename nid2 stnid2
rename nid3 stnid3
rename nid4 stnid4
rename nid5 stnid5
merge m:1 stnid1 using "$dirpath_data_temp/weather_data_for_geonear1.dta", gen(_idmerge)
keep if _idmerge == 3
merge m:1 stnid2 using "$dirpath_data_temp/weather_data_for_geonear2.dta", gen(_idmerge2)
keep if _idmerge2 == 3
merge m:1 stnid3 using "$dirpath_data_temp/weather_data_for_geonear3.dta", gen(_idmerge3)
keep if _idmerge3 == 3
merge m:1 stnid4 using "$dirpath_data_temp/weather_data_for_geonear4.dta", gen(_idmerge4)
keep if _idmerge4 == 3
merge m:1 stnid5 using "$dirpath_data_temp/weather_data_for_geonear5.dta", gen(_idmerge5)
keep if _idmerge5 == 3
keep cds_code stn_call1 stn_call2 stn_call3 stn_call4 stn_call5
drop if cds_code == .
save "$dirpath_data_temp/school_to_weather.dta", replace

**** STEP 3: BUILD SCHOOL-LEVEL WEATHER DATASET
** create a date-hour dataset for schools
use "$dirpath_data_temp/school_to_weather.dta", clear
* make dates
expand 2557 //(2008, 2008, 2009, 2010, 2011, 2012, 2013, 2014)
* assign the correct dates
gen date = .
* start at jan 1 2008
bysort cds_code: replace date = date("January 1 2008", "MDY")
*fill in until dec 31, 2014 for each school
bysort cds_code: replace date = date + (_n - 1)
* create hours
expand 24
* make them from 0 to 23 (to match the electricity data)
bysort cds_code date: gen hour = _n - 1
save "$dirpath_data_temp/school_dates.dta", replace


** grab the actual weather data, and as above, save 5 copies for merging in.
use "$dirpath_data_weather/weather_data_FINAL.dta", clear
drop stn_lon stn_lat
rename date_stata date
save "$dirpath_data_temp/weather_data_formerge.dta", replace
rename stn_call stn_call1
rename temp_f temp_f_1
save "$dirpath_data_temp/weather_data_formerge1.dta", replace
rename stn_call1 stn_call2
rename temp_f temp_f_2
save "$dirpath_data_temp/weather_data_formerge2.dta", replace
rename stn_call2 stn_call3
rename temp_f temp_f_3
save "$dirpath_data_temp/weather_data_formerge3.dta", replace
rename stn_call3 stn_call4
rename temp_f temp_f_4
save "$dirpath_data_temp/weather_data_formerge4.dta", replace
rename stn_call4 stn_call5
rename temp_f temp_f_5
save "$dirpath_data_temp/weather_data_formerge5.dta", replace

** start with the school dataset. Merge in weather data for each of the closest 5 stations.
use "$dirpath_data_temp/school_dates.dta", clear
forvalues i = 1/5 {
merge m:1 stn_call`i' date hour using "$dirpath_data_temp/weather_data_formerge`i'.dta", gen(_weathermerge`i')
drop if cds_code == .
}
** temperature procedure: assign you to the closest weather station temperature. If not available, then the next closest.
 * repeat. The reason I'm ok doing this is that basically all of the stations are within 25km of a school.
gen temp_f = temp_f_1
replace temp_f = temp_f_2 if temp_f == .
replace temp_f = temp_f_3 if temp_f == .
replace temp_f = temp_f_4 if temp_f == .
replace temp_f = temp_f_5 if temp_f == .

* keep only the final variables we need.
keep hour date cds_code temp_f
save "$dirpath_data_int/school_weather_MASTER.dta", replace

**** Collapse temperature data to monthly
use "$dirpath_data_int/school_weather_MASTER.dta", clear

gen daily_t_max = temp_f
gen daily_t_min = temp_f
gen daily_t_mean = temp_f

collapse (max) daily_t_max (min) daily_t_min (mean) daily_t_mean, by(cds_code date)

gen month = month(date)
gen year = year(date)


collapse (mean) daily_t_max daily_t_min daily_t_mean, by(cds_code year month)

expand 24

gen hour = .

bys cds_code year month: replace hour = _n - 1

rename hour block

save "$dirpath_data_int/school_weather_MASTER_monthly.dta", replace

