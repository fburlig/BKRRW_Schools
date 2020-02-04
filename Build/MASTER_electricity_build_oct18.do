************************************************
**** MASTER DO FILE TO BUILD SCHOOL-LEVEL ELECTRICITY DATA
**** WRITTEN BY FIONA BURLIG (fiona.burlig@berkeley.edu)
**** CREATED: August 5, 2015
**** LAST EDITED: August 20, 2015

**** DESCRIPTION: This do-file goes from raw data to a cleaned electricity-only dataset.
			
**** NOTES: 
	*Current inputs: 
		* -- PG&E raw energy data (2008 - 2014) from March 24, 2015 
		* -- PG&E raw energy data (2008 - 2014) from July 28, 2015
		* -- PG&E school-to-meter match from June 29, 2015
		* -- PG&E list of nonres-gas meters
		
	* Data: Everything is going to be aggregated to the HOURLY level for memory/storage constraints
	* File structure: started by putting all of the PG&E electricity data in one folder
	* COME BACK AND FIX: DATES WITH MISSING OBSERVATIONS??
	
**** PROGRAMS:
	   * -- unique (ssc install unique)
	   * -- gsort (ssc install gsort)
		
************************************************
************************************************
**** SETUP
clear all
set more off, perm
version 12

global dirpath "S:/Fiona/Schools"

** additional directory paths to make things easier
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"

************************************************
************************************************
**** CLEAR THE TEMP FOLDER

/*
capture {
  cd "$dirpath_data_temp"
  local tempfiles : dir . files "*.dta"
  foreach file in `tempfiles' {
     erase "`file'"
  }
}
*/

************************************************

/*
**** STEP 1: IMPORT ALL DATA FROM CSVs & SAVE TO STATA

*** 1A: Import 60' interval data 

**************STEP 1: IMPORT ALL NEW DATA, SAVE TO STATA
**** STEP 1A: Import 60' electric interval data
{
** PROGRAM TO CLEAN HOURLY ELECTRICITY DATA
{
capture program drop sixtyminuteclean
program define sixtyminuteclean
  insheet using "`1'", comma clear
  *renaming variables to make things clearer
  * sp_id is service point id (meter ID, essentially)
  rename spid sp_id 
  * flow is the direction of flow (used to check for schools w/ solar)
  rename dir flow
  * rename the energy use variables
  local i = 0
  foreach variable of varlist v9-v32 {
    destring `variable', replace
    replace `variable' = . if `variable' == 0
    rename `variable' qkw_hour`i'
    local i = `i' + 1
  } 
  * put the data into stata format
  gen date_stata = date(date, "MDY")
  drop date
  local year = year(date)
  rename date_stata date
  keep sp_id flow date qkw*
  capture confirm file "$dirpath_data_temp/pge_electric_`year'_pull1_60.dta" 
  if _rc == 0 {
      save "$dirpath_data_temp/pge_electric_`year'_pull2_60.dta", replace
  } 
  else {
    save "$dirpath_data_temp/pge_electric_`year'_pull1_60.dta", replace
  }
  clear
end
}

** RUN THE PROGRAM ON THE MAR 24 AND JUL 31 DATA


cd "$dirpath_data_raw/PGE_energy_combined/Unzipped electric 60 min"
** 2008
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242008.20150310131216.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102008.20150717071141.csv"

** 2009
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242009.20150310134715.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102009.20150717074157.csv"

** 2010
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242010.20150310142207.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102010.20150720115153.csv"

** 2011
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242011.20150310150223.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102011.20150720120151.csv"

** 2012
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242012.20150310153708.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102012.20150720121149.csv"

** 2013
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242013.20150311070709.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102013.20150720122713.csv"

** 2014
sixtyminuteclean  "IDA.60MIN.AEG3.DR152242014.20150311080701.csv"
sixtyminuteclean  "IDA.60MIN.AEG3.DR1507102014.20150720123642.csv"



cd "$dirpath_data_temp"

local files : dir . files "*60.dta"
foreach file in `files' {
	append using `file'
}
save "$dirpath_data_temp/pge_electric_allyears_60.dta", replace
* tag schools with solar
gen rev_flow = 0
replace rev_flow = 1 if flow == "R"
egen meter_has_solar = max(rev_flow), by(sp_id)
** keeping this indicator around so we can make sure not to include these schools later
drop if flow == "R"
drop if flow == "*" & meter_has_solar == 1
drop rev_flow flow
** reshape this
egen meter_date = group(sp_id date)
reshape long qkw_hour, i(meter_date) j(hour)
gen missingdata = 0
replace missingdata = 1 if qkw_hour ==. | qkw_hour == 0
save "$dirpath_data_temp/pge_allyears_60_reshape.dta", replace
}


**** STEP 1B: Import 15' electric interval data

* we'll sum to hourly after we do this; this will allow us to check for missing obs
* THIS TAKES FOREVER. AVOID DOING IT AGAIN!

{
capture program drop fifteenminuteclean
program define fifteenminuteclean
  insheet using "`1'", comma clear
  *renaming variables so they match our other convention
  rename spid sp_id 
  rename dir flow
  local i = 0
  foreach variable of varlist v9-v104 {
    destring `variable', replace
    replace `variable' = . if `variable' == 0
    rename `variable' qkw`i'
    local i = `i' + 1
  } 
  gen date_stata = date(date, "MDY")
  drop date
  rename date_stata date
  local year = year(date)
  keep sp_id flow date qkw*
    capture confirm file "$dirpath_data_temp/pge_electric_`year'_pull1_15.dta" 
  if _rc == 0 {
      save "$dirpath_data_temp/pge_electric_`year'_pull2_15.dta", replace
  } 
  else {
    save "$dirpath_data_temp/pge_electric_`year'_pull1_15.dta", replace
  }
  clear
end
}

cd "$dirpath_data_raw/PGE_energy_combined/Unzipped electric 15 min"
** 2008
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242008.20150310131216.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102008.20150717071141.csv"

** 2009
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242009.20150310134715.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102009.20150717074157.csv"

** 2010
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242010.20150310142207.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102010.20150720115153.csv"

** 2011
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242011.20150310150223.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102011.20150720120151.csv"

** 2012
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242012.20150310153708.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102012.20150720121149.csv"

** 2013
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242013.20150311070709.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102013.20150720122713.csv"

** 2014
fifteenminuteclean  "IDA.15MIN.AEG3.DR152242014.20150311080701.csv"
fifteenminuteclean  "IDA.15MIN.AEG3.DR1507102014.20150720123642.csv"




cd "$dirpath_data_temp"

local files : dir . files "*15.dta"
foreach file in `files' {
	append using `file'
}
save "$dirpath_data_temp/pge_electric_allyears_15.dta", replace

* tag schools with solar
gen rev_flow = 0
replace rev_flow = 1 if flow == "R"
egen meter_has_solar = max(rev_flow), by(sp_id)
** keeping this indicator around so we can make sure not to include these schools later
drop if flow == "R"
drop if flow == "*" & meter_has_solar == 1
drop rev_flow flow
** reshape this
egen meter_date = group(sp_id date)
duplicates drop
gen datasplit_count = _n
** we're going to reshape by slicing up the dataset - this is annoying, but should be faster.
 preserve
local d = 0
forvalues c = 100000(100000)12000000 {
  local k = `c'-100000 
  keep if datasplit_count > `k' & datasplit_count <= `c'
  reshape long qkw, i(meter_date) j(fifteenmin)
  save "$dirpath_data_temp/pge_15_reshape_`d'.dta", replace
  local d = `d' + 1
  restore, preserve
}
restore


** create a general crosswalk b/w 15' & hourly data
clear
set obs 96
gen int fifteenmin = _n - 1
gen int hour = .
forvalues i = 0/3 {
  replace hour = 0 if fifteenmin == `i'
}
forvalues i = 4/7 {
  replace hour = 1 if fifteenmin == `i'
}
forvalues i = 8/11 {
  replace hour = 2 if fifteenmin == `i'
}
forvalues i = 12/15 {
  replace hour = 3 if fifteenmin == `i'
}
forvalues i = 16/19 {
  replace hour = 4 if fifteenmin == `i'
}
forvalues i = 20/23 {
  replace hour = 5 if fifteenmin == `i'
}
forvalues i = 24/27 {
  replace hour = 6 if fifteenmin == `i'
}
forvalues i = 28/31 {
  replace hour = 7 if fifteenmin == `i'
}
forvalues i = 32/35 {
  replace hour = 8 if fifteenmin == `i'
}
forvalues i = 36/39 {
  replace hour = 9 if fifteenmin == `i'
}
forvalues i = 40/43 {
  replace hour = 10 if fifteenmin == `i'
}
forvalues i = 44/47 {
  replace hour = 11 if fifteenmin == `i'
}
forvalues i = 48/51 {
  replace hour = 12 if fifteenmin == `i'
}
forvalues i = 52/55 {
  replace hour = 13 if fifteenmin == `i'
}
forvalues i = 56/59 {
  replace hour = 14 if fifteenmin == `i'
}
forvalues i = 60/63 {
  replace hour = 15 if fifteenmin == `i'
}
forvalues i = 64/67 {
  replace hour = 16 if fifteenmin == `i'
}
forvalues i = 68/71 {
  replace hour = 17 if fifteenmin == `i'
}
forvalues i = 72/75 {
  replace hour = 18 if fifteenmin == `i'
}
forvalues i = 76/79 {
  replace hour = 19 if fifteenmin == `i'
}
forvalues i = 80/83 {
  replace hour = 20 if fifteenmin == `i'
}
forvalues i = 84/87 {
  replace hour = 21 if fifteenmin == `i'
}
forvalues i = 88/91 {
  replace hour = 22 if fifteenmin == `i'
}
forvalues i = 92/95 {
  replace hour = 23 if fifteenmin == `i'
}
compress
save "$dirpath_data_temp/fifteenmin_hour_crosswalk.dta", replace
clear

*** collapsing to the hourly level; keeping track of missing obs
cd "$dirpath_data_temp"
local d = 0
local reshaped: dir . files "pge_15_reshape*"
foreach dta in `reshaped' {
  use "`dta'", clear
  gen int missingdata = 0
  replace missingdata = 1 if qkw ==. | qkw == 0
  merge m:1 fifteenmin using "$dirpath_data_temp/fifteenmin_hour_crosswalk.dta", nogenerate
  tsset meter_date fifteenmin
  replace qkw = (L.qkw + F.qkw)/2 if missing==1 & L.missing==0 & F.missing==0
  replace missing = 0 if missing==1 & L.missing==0 & F.missing==0 & qkw !=. & qkw != 0 
  collapse (mean) qkw missingdata meter_has_solar, by(sp_id date hour)
  rename qkw qkw_hour
  replace qkw = qkw * 4
  replace meter_has_solar = 1 if meter_has_solar >0 & meter_has_solar !=.
  replace missingdata = 1 if missingdata >0 & missingdata !=.
  compress *
  save "$dirpath_data_temp/pge_15_collapsed_`d'.dta", replace
  local d = `d' + 1
}



**** STEP 1D: Combine collapsed 15' & hourly data & collapse to school level
cd "$dirpath_data_temp"
local collapsed: dir . files "pge_15_collapsed_*"
foreach dta in `collapsed' {
  di "`dta'"
  append using "`dta'"
}
replace meter_has_solar = . if meter_has_solar == 0
append using "$dirpath_data_temp/pge_allyears_60_reshape.dta"
compress
save "$dirpath_data_temp/pge_newinterval_full.dta", replace

** We need to account for missing data before we sum meters to the school level
* we should have data for jan 1, 2008 - dec 31, 2014
* create an empty dataset of dates
clear
set obs 2557 // (366 + 365 + 365 + 365 + 366 + 365 + 365)
gen date = .
replace date = date("January 1 2008", "MDY") in 1
gen obsnum = _n - 1
replace date = date[1] + obsnum
drop obsnum
format date %td
expand 24
bysort date: gen hour = _n - 1
compress
save "$dirpath_data_temp/dates_energy.dta", replace

use "$dirpath_data_temp/pge_newinterval_full.dta", clear
duplicates drop
gen byte zeroflag = 0
replace zeroflag = 1 if qkw == 0
* create a new 1-N group variable to loop over
egen metergroup = group(sp_id)
egen metermax = max(metergroup)
* create a local equal to the number of meters
local metermax = metermax
drop metermax
compress

preserve
forvalues i = 1/`metermax' {
  keep if metergroup == `i'
  merge m:1 date hour using "$dirpath_data_temp/dates_energy.dta"
  gsort - _merge
  replace sp_id = sp_id[1] if sp_id == .
  replace missingdata = 1 if _merge !=3
  replace zeroflag = 1 if qkw == 0
  drop _merge
  save "$dirpath_data_temp/elec_`i'_dates.dta", replace
  restore, preserve
}
restore

clear
forvalues i = 1/`metermax' {
  di "`i'"
  append using "$dirpath_data_temp/elec_`i'_dates.dta"
}
compress
save "$dirpath_data_temp/pge_newelec_dates_full.dta", replace

*/

**** STEP 1D.I: Get PGE's school to meter match ready for use --- WITH CLUSTERS AS WELL

** prior step - grab the gas data out of here so we're not worried about elec-gas clusters
/* these meters are electric meters
import delimited "$dirpath_data_raw/Non-Res SPs LatLong.txt", clear
keep sp_id
rename sp_id spid
duplicates drop
compress
save "$dirpath_data_temp/nonres_sps.dta", replace
*/

import delimited "$dirpath_data_raw/Non-Res Gas SPs LatLong.txt", clear
gen gas = 1
keep sp_id gas
duplicates drop
tostring sp_id, replace
compress
save "$dirpath_data_temp/nonres_gas_sps.dta", replace


*** Clean PG&E's meter match list (and deal with clusters)
import excel "$dirpath_data_raw/PGE_Oct_2016/PGE School Meter Matching to UCB 20161017.xlsx", sheet("All_Match") firstrow clear
keep CDS_CODE SP_ID
rename *, lower
merge m:1 sp_id using "$dirpath_data_temp/nonres_gas_sps.dta"
* gets rid of all the gas meters (since we're only doing electric here)
drop if _merge > 1
drop _merge gas

* get rid of duplicated meter-school pairs (sometimes we see duplicates in the data)
duplicates drop sp_id cds_code, force

* tag guys where we see a meter appear with more than one school (indicates problems)
duplicates tag sp_id, gen(duplicate_sp_id)
replace duplicate_sp_id =1 if duplicate_sp_id >0

* if a meter only appears once, we don't have to deal with it specially
gen matching_required = "no"
replace matching_required = "yes" if duplicate_sp_id ==1

*** walter's fancy clustering algorithm. basically, grabs
** all of the meters/schools that are pairwise associated
** and marks them as such

egen group2 = group(cds_code)
egen group1 = group(sp_id)
sort group1 group2

sort cds_code sp_id
bysort group2 (group1): replace group2 = group1[1]
bysort group1 (group2): replace group1 = group2[1]
bysort group2 (group1): replace group2 = group1[1]
bysort group1 (group2): replace group1 = group2[1]
bysort group2 (group1): replace group2 = group1[1]
bysort group1 (group2): replace group1 = group2[1]
drop group2
*sequentially number the groups
egen group = group(group1) 
drop group1

* tag you if a group includes meters that are matched to multiple schools
gen matching_required_num = 0
replace matching_required_num = 1 if matching_required == "yes"
egen matching_required_sum = sum(matching_required_num), by(group)
* keep only the NON-CLUSTERED guys
preserve
keep if matching_required_sum == 0 
keep cds_code sp_id 
compress
save "$dirpath_data_int/pge_lea_meter_crosswalk_oct2016.dta", replace
* keep only the CLUSTERED guys
restore
keep if matching_required_sum > 0 & matching_required_sum !=.
* count the number of schools in a cluster
unique cds_code, by(group) generate(cluster_schools_prelim)
* count the number of meters in a cluster
unique sp_id, by(group) generate(cluster_meters_prelim)
egen cluster_schools = max(cluster_schools_prelim), by(group)
egen cluster_meters = max(cluster_meters_prelim), by(group)
drop cluster_schools_prelim cluster_meters_prelim matching_required_num ///
   matching_required_sum matching_required duplicate_sp_id
* create a new cluster identifier that's from 1-max
egen cluster = group(group)
save "$dirpath_data_int/pge_lea_meter_crosswalk_CLUSTERS_oct2016.dta", replace

collapse(mean) cluster_schools cluster_meters, by(cluster)
compress
save "$dirpath_data_int/pge_lea_meter_crosswalk_collapsed_CLUSTERS_oct2016.dta", replace


**** TRY THE JOINBY ON THE NON-CLUSTERED GUYS


**** STEP 1D.III
cd "$dirpath_data_temp"
* open the full gas dataset
use "$dirpath_data_temp/pge_newelec_dates_full.dta", clear
tostring sp_id, replace
joinby sp_id using "$dirpath_data_int/pge_lea_meter_crosswalk_oct2016.dta"
* get rid of doubled observations before we collapse to the cluster level
duplicates drop
* collapse to school level
*replace missings as zeros because the collapse won't work otherwise
replace qkw_hour = 0 if qkw_hour == .
collapse (sum) qkw_hour missingdata zeroflag meter_has_solar, by(cds_code date hour)
replace missingdata = 1 if missingdata >0 & missingdata !=.
replace zeroflag = 1 if zeroflag >0 & zeroflag !=.
replace meter_has_solar = 1 if meter_has_solar >0 & meter_has_solar !=.
rename missingdata problematic_obs
	
/*
* create some school year identifiers --not sure why we would want them here
gen schoolyear = ""
replace schoolyear = "0809" if date >= mdy(09, 01, 2008) & date <= mdy(06, 30, 2009)
replace schoolyear = "0910" if date >= mdy(09, 01, 2009) & date <= mdy(06, 30, 2010)
replace schoolyear = "1011" if date >= mdy(09, 01, 2010) & date <= mdy(06, 30, 2011)
replace schoolyear = "1112" if date >= mdy(09, 01, 2011) & date <= mdy(06, 30, 2012)
replace schoolyear = "1213" if date >= mdy(09, 01, 2012) & date <= mdy(06, 30, 2013)
replace schoolyear = "1314" if date >= mdy(09, 01, 2013) & date <= mdy(06, 30, 2014)
replace schoolyear = "1415" if date >= mdy(09, 01, 2014) & date <= mdy(06, 30, 2015)
*/

compress
save "$dirpath_data_int/pge_electricity_MASTER_oct2016.dta", replace



**** STEP 1D.III(B) DEAL WITH CLUSTERS
cd "$dirpath_data_temp"
* open the full gas dataset
use "$dirpath_data_temp/pge_newelec_dates_full.dta", clear
tostring sp_id, replace
joinby sp_id using "$dirpath_data_int/pge_lea_meter_crosswalk_CLUSTERS_oct2016.dta"
* get rid of doubled observations before we collapse to the cluster level
drop cds_code
duplicates drop
compress
save "$dirpath_data_int/pge_electricity_cluster_precollapse_oct2016.dta", replace


* collapse to cluster level
collapse(sum) qkw_hour missingdata zeroflag meter_has_solar (mean) cluster_schools cluster_meters, by(cluster date hour)
replace missingdata = 1 if missingdata >0 & missingdata !=.
replace zeroflag = 1 if zeroflag >0 & zeroflag !=.
replace meter_has_solar = 1 if meter_has_solar >0 & meter_has_solar !=.
rename missingdata problematic_obs
	
* create some school year identifiers
gen schoolyear = ""
replace schoolyear = "0809" if date >= mdy(09, 01, 2008) & date <= mdy(06, 30, 2009)
replace schoolyear = "0910" if date >= mdy(09, 01, 2009) & date <= mdy(06, 30, 2010)
replace schoolyear = "1011" if date >= mdy(09, 01, 2010) & date <= mdy(06, 30, 2011)
replace schoolyear = "1112" if date >= mdy(09, 01, 2011) & date <= mdy(06, 30, 2012)
replace schoolyear = "1213" if date >= mdy(09, 01, 2012) & date <= mdy(06, 30, 2013)
replace schoolyear = "1314" if date >= mdy(09, 01, 2013) & date <= mdy(06, 30, 2014)
replace schoolyear = "1415" if date >= mdy(09, 01, 2014) & date <= mdy(06, 30, 2015)

compress
save "$dirpath_data_int/pge_electricity_MASTER_clusters_oct2016.dta", replace
