************************************************
*** BUILD DATA FOR MATCHING ANALYSIS
************************************************
*** ANY energy use setup
{
**** Import data:
use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear

*** STEP 1: Set up variables on which to match
** Matching variables: block-wise mean/SD (PRE-TREATMENT), and demogs
egen evertreated_a = max(upgr_counter_all), by(cds_code)
replace evertreated_a = 1 if evertreated_a > 0 & evertreated_a !=.
keep date cds_code block qkw_hour evertreated_a any_post_treat

gen dow = dow(date)
gen weekend = 0
replace weekend = 1 if dow == 0 | dow == 6
/*
gen year = year(date)
gen summer = 0
forvalues year = 2008/2014 {
  replace summer = 1 if date >= mdy(06,01,`year') & date <= mdy(09,01,`year')
}
*/
*** keep only weekday observations
keep if weekend == 0

** Set up variables for collapsing. We will do three sets: 1) HOUR-BLOCK averages 2) OVERALL averages 3) DAILY averages (averaged)
gen kwh_max = qkw_hour
gen kwh_mean = qkw_hour
gen kwh_sd = qkw_hour

*** block-wise collapse
preserve
collapse (max) kwh_max (mean) evertreated_a kwh_mean (sd) kwh_sd, by(cds_code block)
reshape wide kwh_*, i(cds_code) j(block)
save "$dirpath_data_temp/any_block_energy_use_collapse.dta", replace

*** overall average collapse
restore, preserve
collapse (max) kwh_max (mean) evertreated_a kwh_mean (sd) kwh_sd, by(cds_code)
rename kwh_max kwh_max_overall
rename kwh_mean kwh_mean_overall
rename kwh_sd kwh_sd_overall

save "$dirpath_data_temp/any_overall_energy_use_collapse.dta", replace

restore
collapse (max) kwh_max (mean) evertreated_a kwh_mean (sd) kwh_sd, by(cds_code date)
collapse (mean) evertreated_a kwh_max kwh_mean kwh_sd, by(cds_code)
rename kwh_max kwh_max_dailyavg
rename kwh_mean kwh_mean_dailyavg
rename kwh_sd kwh_sd_dailyavg

save "$dirpath_data_temp/any_dailyavgs_energy_use_collapse.dta", replace
*** merge these badboys together


use "$dirpath_data_temp/any_dailyavgs_energy_use_collapse.dta", clear
merge 1:1 cds_code using "$dirpath_data_temp/any_block_energy_use_collapse.dta", nogen
merge 1:1 cds_code using "$dirpath_data_temp/any_overall_energy_use_collapse.dta", nogen
save "$dirpath_data_temp/any_energyformatch_merged.dta", replace
}



*** Demographic information -- first, collapse this demographic data to the school level
{
use "$dirpath_data_other/Demographics/schools_comparison_no_weights.dta", clear
merge m:1 county using "$dirpath_data_other/Demographics/data_presidential_county.dta", gen(_presmerge)
keep if _presmerge == 3

gen stata_open_date = date(opendate,"YMD")
gen school_age = (date("$S_DATE","DMY") - stata_open_date) / 365
gen school_age2 = school_age^2

gen elementary = regexm(soctype,"Elem")
gen middle = regexm(soctype,"Middle") | regexm(soctype,"Junior")
gen high = regexm(soctype,"^High") 
gen k12 = regexm(soctype,"K-12")
gen other = 1 - (elementary + middle + high + k12)

**** COLLAPSE TO GET ONE SCHOOL OBSERVATION
collapse(mean) median_age_male median_age_female pct_black pct_hispanic pct_AmIndian pct_asian pct_other pct_mixed ///
PCT_AA PCT_AI PCT_AS PCT_FI PCT_HI PCT_PI PCT_WH PCT_MR ///
pct_pub_trans pct_walk_bike pct_work_at_home ///
pct_hs_male pct_associates_male pct_bachelors_male pct_masters_male pct_doctorate_male ///
pct_hs_female pct_associates_female pct_bachelors_female pct_masters_female pct_doctorate_female ///
pct_hs pct_associates pct_bachelors pct_masters pct_doctorate ///
NOT_HSG HSG SOME_COL COL_GRAD GRAD_SCH ///
pct_single_mom poverty_rate ln_pc_inc ///
winter_max winter_min spring_max spring_min summer_max summer_min fall_max fall_min ///
winter_ave spring_ave summer_ave fall_ave ///
winter_cdd winter_hdd spring_cdd spring_hdd summer_cdd summer_hdd fall_cdd fall_hdd ///
hdd cdd enr_total API_BASE school_age school_age2 elementary middle high k12 ///
ca_climate_zone_id, by(cds_code)

gen ln_enr_total = log(enr_total)

** grab the school district to do out-of-district matches
tostring cds_code, gen(cds_string) format(%25.0f)
gen district = substr(cds_string, 3, 5)
egen distr_id = group(district)

gen rand = runiform()
gen schoolnum = _n
save "$dirpath_data_other/Demographics/demographics_all_collapsed.dta", replace
}










*** Demographic Information -- merge into school energy data


use "$dirpath_data_other/Demographics/demographics_all_collapsed.dta", clear
merge 1:1 cds_code using "$dirpath_data_temp/any_energyformatch_merged.dta", keep(match) nogen
save "$dirpath_data_temp/any_with_demogs_formatch.dta", replace

local income_vars = "poverty_rate ln_pc_inc "
local school_vars = "enr_total API_BASE school_age school_age2 elementary middle high k12"


****** NEAREST NEIGHBOR:
** ANY

use "$dirpath_data_temp/any_with_demogs_formatch.dta", clear

* keep covariates to match on; drop observations if matching vars are empty
keep  evertreated_a rand kwh_* winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars' distr_id cds_code cds_string
sort evertreated_a cds_code
foreach var of varlist kwh_* winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars' {
 drop if `var' == .
}

* save a complete; treated; ctrl version
save "$dirpath_data_temp/any_prematch_dataset_all.dta", replace
preserve

keep if evertreated_a == 0
save "$dirpath_data_temp/any_prematch_dataset_CONTROLS.dta", replace

restore
keep if evertreated_a == 1
save "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", replace



**** MATCH
{
** these matches use the built-in NN match (don't need to be specially done to deal with districts)
use "$dirpath_data_temp/any_prematch_dataset_all.dta", clear
**** DISTRICT FREE
** DAILYAVG ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max_dailyavg kwh_mean_dailyavg kwh_sd_dailyavg winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_dailyavg_nnmatch.dta") replace
** BLOCKS ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max1 kwh_mean1 kwh_sd1 kwh_max2 kwh_mean2 kwh_sd2 kwh_max3 kwh_mean3 kwh_sd3 kwh_max4 kwh_mean4 kwh_sd4 kwh_max5 kwh_mean5 kwh_sd5 kwh_max6 kwh_mean6 kwh_sd6 kwh_max7 kwh_mean7 kwh_sd7 kwh_max8 kwh_mean8 kwh_sd8 winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_blocks_nnmatch.dta") replace
** OVERALL ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max_overall kwh_mean_overall kwh_sd_overall winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_overall_nnmatch.dta") replace


**** DISTRICT - OPPOSITE
** to do these, we'll keep treated school i and every control school not in i's district 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear

local bign = _N
preserve
 forvalues i = 1/`bign' {
 keep in `i'
 append using "$dirpath_data_temp/any_prematch_dataset_CONTROLS.dta"
 ** drops everyone who is IN my district
 cap drop districtgroup
 gen districtgroup = 0
 replace districtgroup = 1 if distr_id == distr_id[1]
 replace districtgroup = 0 in 1
 drop if districtgroup == 1
 di `i'
  gen total = _N
 if _N == 2 {
	keep rand evertreated_a
	gen id = _n
	gen index = .
	replace index = 2 in 1
	* if only one school is outside your district, match to it!
	di "ONLY ONE OBSERVATION"
	save "$dirpath_data_temp/any_dailyavg_`i'.dta", replace
	save "$dirpath_data_temp/any_blocks_`i'.dta", replace
	save "$dirpath_data_temp/any_overall_`i'.dta", replace
	restore, preserve
	continue
 }
 * now that we have the sample, do the match
** DAILYAVG ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max_dailyavg kwh_mean_dailyavg kwh_sd_dailyavg winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_dailyavg_`i'.dta") replace
** BLOCKS ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max1 kwh_mean1 kwh_sd1 kwh_max2 kwh_mean2 kwh_sd2 kwh_max3 kwh_mean3 kwh_sd3 kwh_max4 kwh_mean4 kwh_sd4 kwh_max5 kwh_mean5 kwh_sd5 kwh_max6 kwh_mean6 kwh_sd6 kwh_max7 kwh_mean7 kwh_sd7 kwh_max8 kwh_mean8 kwh_sd8 winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_blocks_`i'.dta") replace
** OVERALL ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
nnmatch rand evertreated_a kwh_max_overall kwh_mean_overall kwh_sd_overall winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_overall_`i'.dta") replace
  
 
 restore, preserve
}
restore
 
 

 
 **** DISTRICT - EXACT
 ** this version keeps only schools who share i's district
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear

local bign = _N
preserve
 forvalues i = 1/`bign' {
 keep in `i'
 append using "$dirpath_data_temp/any_prematch_dataset_CONTROLS.dta"
 ** drops everyone who is NOT in my district
 cap drop districtgroup
 gen districtgroup = 0
 replace districtgroup = 1 if distr_id == distr_id[1]
 drop if districtgroup == 0
 di `i'
  gen total = _N
 if _N == 2 {
	keep rand evertreated_a 
	gen id = _n
	gen index = .
	replace index = 2 in 1
	di "ONLY ONE OBSERVATION"
	save "$dirpath_data_temp/any_dailyavg_`i'_exact.dta", replace
	save "$dirpath_data_temp/any_blocks_`i'_exact.dta", replace
	save "$dirpath_data_temp/any_overall_`i'_exact.dta", replace
	restore, preserve
	continue
 }
** DAILYAVG ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
cap nnmatch rand evertreated_a kwh_max_dailyavg kwh_mean_dailyavg kwh_sd_dailyavg winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_dailyavg_`i'_exact.dta") replace
** BLOCKS ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
cap nnmatch rand evertreated_a kwh_max1 kwh_mean1 kwh_sd1 kwh_max2 kwh_mean2 kwh_sd2 kwh_max3 kwh_mean3 kwh_sd3 kwh_max4 kwh_mean4 kwh_sd4 kwh_max5 kwh_mean5 kwh_sd5 kwh_max6 kwh_mean6 kwh_sd6 kwh_max7 kwh_mean7 kwh_sd7 kwh_max8 kwh_mean8 kwh_sd8 winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_blocks_`i'_exact.dta") replace
** OVERALL ENERGY USE (ALL YEARS): CDD/HDD, ENROLLMENT - ALL DISTRICTS
cap nnmatch rand evertreated_a kwh_max_overall kwh_mean_overall kwh_sd_overall winter_hdd spring_hdd summer_cdd fall_cdd `school_vars' `income_vars', keep("$dirpath_data_temp/any_overall_`i'_exact.dta") replace
 
 restore, preserve
}
restore
}
clear



*************** PUT TOGETHER THE MATCHES
** THIS SECTION COLLECTS CDS CODES FOR T/C MATCHES TO MERGE INTO THE ENERGY DATA LATER
{
*** NO DISTRICT RESTRICTIONS
use "$dirpath_data_temp/any_dailyavg_nnmatch.dta", clear
* get treated guys at the top of the dataset - important!
gsort -evertreated_a
keep evertreated_a rand id index
gen counter = _n
preserve
keep if evertreated_a == 1
* count the treated units
local bign = _N
restore, preserve
forvalues i = 1/`bign' {
  * keep any unit after this unit (essentially keeping the controls, and lets i --> [1])
  keep if counter >= `i'
  * keep if you are unit i or if you're matched to unit i
  keep if id == id[1] | id == index[1]
  keep rand evertreated_a
  * grab school demographics (CDS code) - rand uniquely identifies the school.
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
	* the control is the cds code of the 2nd observation
    gen cds_controlmatch_prelim = cds_string[2]
	* the treated is the cds code of the 1st observation
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
	* drop in the case of ties
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_ANY.dta", replace
	restore, preserve
}
restore

use "$dirpath_data_temp/any_blocks_nnmatch.dta", clear
gsort -evertreated_a
keep evertreated_a rand id index
gen counter = _n
preserve
keep if evertreated_a == 1
local bign = _N
restore, preserve
forvalues i = 1/`bign' {
  keep if counter >= `i'
  keep if id == id[1] | id == index[1]
  keep rand evertreated_a 
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_ANY.dta", replace
	restore, preserve
}
restore


use "$dirpath_data_temp/any_overall_nnmatch.dta", clear
gsort -evertreated_a
keep evertreated_a rand id index
gen counter = _n
preserve
keep if evertreated_a == 1
local bign = _N
restore, preserve
forvalues i = 1/`bign' {
  keep if counter >= `i'
  keep if id == id[1] | id == index[1]
  keep rand evertreated_a 
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_ANY.dta", replace
	restore, preserve
}
restore


*** DAILY
** matches from OPPOSITE districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  di `i'
  cap confirm file "$dirpath_data_temp/any_dailyavg_`i'.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_dailyavg_`i'.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a 
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_OPPOSITE.dta", replace
  }
}


*************
** matches from THE SAME districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_dailyavg_`i'_exact.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_dailyavg_`i'_exact.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_EXACT.dta", replace
  }
}


*** BLOCK
** matches from OPPOSITE districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  di `i'
  cap confirm file "$dirpath_data_temp/any_blocks_`i'.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_blocks_`i'.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a 
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_OPPOSITE.dta", replace
  }
}


*************
** matches from THE SAME districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_blocks_`i'_exact.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_blocks_`i'_exact.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_EXACT.dta", replace
  }
}


*** DAILY
** matches from OPPOSITE districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  di `i'
  cap confirm file "$dirpath_data_temp/any_overall_`i'.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_overall_`i'.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a 
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_OPPOSITE.dta", replace
  }
}


*************
** matches from THE SAME districts 
use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_overall_`i'_exact.dta"
  if _rc == 0 {
  di `i'
    use "$dirpath_data_temp/any_overall_`i'_exact.dta", clear
    keep if id==1 | id == index[1]
    keep rand evertreated_a
    merge 1:1 rand evertreated_a using "$dirpath_data_temp/any_with_demogs_formatch.dta", gen(_merge)
    keep if _merge == 3
    gsort - evertreated_a
    gen cds_controlmatch_prelim = cds_string[2]
    gen cds_treatmatch_prelim = cds_string[1]
    destring cds_controlmatch_prelim, gen(cds_controlmatch)
    destring cds_treatmatch_prelim, gen(cds_treatmatch)
    keep cds_code cds_treatmatch cds_controlmatch evertreated_a
    format cds* %25.0f
    gen counter = _n
    drop if counter >2
    drop counter
	save "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_EXACT.dta", replace
  }
}
}




****** CREATE LISTS OF CDS CODES FROM THE MATCHES THAT WILL MAKE UP THE FINAL SAMPLE
{

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
* grab all of the possible treated schools
forvalues i = 1/`bign' {
* for each treated school, make sure it actually exists in the matched sample
  cap confirm file "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_EXACT.dta"
  if _rc == 0 {
  * append to create a full list of treat-control pairs
  append using "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_EXACT.dta"
  }
}
* save
save "$dirpath_data_temp/any_overall_EXACT.dta", replace

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
* grab all of the possible treated schools
forvalues i = 1/`bign' {
* for each treated school, make sure it actually exists in the matched sample
  cap confirm file "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_EXACT.dta"
  if _rc == 0 {
  * append to create a full list of treat-control pairs
  append using "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_EXACT.dta"
  }
}
* save
save "$dirpath_data_temp/any_blocks_EXACT.dta", replace


use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
* grab all of the possible treated schools
forvalues i = 1/`bign' {
* for each treated school, make sure it actually exists in the matched sample
  cap confirm file "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_EXACT.dta"
  if _rc == 0 {
  * append to create a full list of treat-control pairs
  append using "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_EXACT.dta"
  }
}
* save
save "$dirpath_data_temp/any_dailyavg_EXACT.dta", replace





use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  }
}
save "$dirpath_data_temp/any_dailyavg_OPPOSITE.dta", replace

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  }
}
save "$dirpath_data_temp/any_blocks_OPPOSITE.dta", replace

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_OPPOSITE.dta"
  }
}
save "$dirpath_data_temp/any_overall_OPPOSITE.dta", replace




use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_ANY.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_overall_nnmatch_cdscodes_`i'_ANY.dta"
  }
}
save "$dirpath_data_temp/any_overall_ANY.dta", replace

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_ANY.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_blocks_nnmatch_cdscodes_`i'_ANY.dta"
  }
}
save "$dirpath_data_temp/any_blocks_ANY.dta", replace

use "$dirpath_data_temp/any_prematch_dataset_TREATED.dta", clear
local bign = _N
clear
forvalues i = 1/`bign' {
  cap confirm file "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_ANY.dta"
  if _rc == 0 {
  append using "$dirpath_data_temp/any_dailyavg_nnmatch_cdscodes_`i'_ANY.dta"
  }
}
save "$dirpath_data_temp/any_dailyavg_ANY.dta", replace

}




**** CREATE ENERGY DATA FOR THE MATCHED SAMPLES

{
* subsetting now just makes this easier. 
use "$dirpath_data_temp/any_dailyavg_ANY.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_dailyavg_TREATED_ANY.dta", replace
use "$dirpath_data_temp/any_dailyavg_ANY.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_dailyavg_CONTROL_ANY.dta", replace

use "$dirpath_data_temp/any_dailyavg_OPPOSITE.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_dailyavg_TREATED_OPPOSITE.dta", replace
use "$dirpath_data_temp/any_dailyavg_OPPOSITE.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_dailyavg_CONTROL_OPPOSITE.dta", replace

use "$dirpath_data_temp/any_dailyavg_EXACT.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_dailyavg_TREATED_EXACT.dta", replace
use "$dirpath_data_temp/any_dailyavg_EXACT.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_dailyavg_CONTROL_EXACT.dta", replace



use "$dirpath_data_temp/any_overall_ANY.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_overall_TREATED_ANY.dta", replace
use "$dirpath_data_temp/any_overall_ANY.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_overall_CONTROL_ANY.dta", replace

use "$dirpath_data_temp/any_overall_OPPOSITE.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_overall_TREATED_OPPOSITE.dta", replace
use "$dirpath_data_temp/any_overall_OPPOSITE.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_overall_CONTROL_OPPOSITE.dta", replace

use "$dirpath_data_temp/any_overall_EXACT.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_overall_TREATED_EXACT.dta", replace
use "$dirpath_data_temp/any_overall_EXACT.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_overall_CONTROL_EXACT.dta", replace


use "$dirpath_data_temp/any_blocks_ANY.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_blocks_TREATED_ANY.dta", replace
use "$dirpath_data_temp/any_blocks_ANY.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_blocks_CONTROL_ANY.dta", replace

use "$dirpath_data_temp/any_blocks_OPPOSITE.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_blocks_TREATED_OPPOSITE.dta", replace
use "$dirpath_data_temp/any_blocks_OPPOSITE.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_blocks_CONTROL_OPPOSITE.dta", replace

use "$dirpath_data_temp/any_blocks_EXACT.dta", clear
keep if evertreated_a == 1
save "$dirpath_data_temp/any_blocks_TREATED_EXACT.dta", replace
use "$dirpath_data_temp/any_blocks_EXACT.dta", clear
keep if evertreated_a == 0
save "$dirpath_data_temp/any_blocks_CONTROL_EXACT.dta", replace


}


****************************** THIS BEGINS TO DIFFER FROM THE REST OF THE MATCHING STUFF


**** ACTUALLY MATCH THIS TO ENERGY DATA
** CREATE A DATASET THAT CONTAINS ONLY THE ``CONTROL MATCHES'' & VARIABLES WE WANT
use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
rename cds_code cds_controlmatch
rename prediction_error_log prediction_error_log_match
rename log_kwh log_kwh_match 
keep cds_controlmatch prediction_error_log_match log_kwh_match any_post_treat block date
egen evertreat = max(any_post_treat), by(cds_controlmatch)
keep if evertreat == 0
save "$dirpath_data_temp/control_energy_data.dta", replace

** MATCH TO ENERGY DATA AND CREATE THE SAMPLE OF MATCHED GUYS
* get rid of any schools that matched multiple times (take a random one)
foreach districttype in ANY EXACT OPPOSITE {
 foreach matchtype in dailyavg blocks overall {
 use "$dirpath_data_temp/any_`matchtype'_TREATED_`districttype'.dta", clear
 duplicates drop
 duplicates tag cds_code, gen(dupes)
 bysort dupes cds_code: gen counter = _n
 drop if counter > 1 & dupes > 0
 drop dupes counter
 save, replace
 }
}


foreach districttype in ANY EXACT OPPOSITE {
  foreach matchtype in dailyavg blocks overall {
  * main energy dataset
use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
	* merge in for the treated guys
	merge m:1 cds_code using "$dirpath_data_temp/any_`matchtype'_TREATED_`districttype'.dta", gen(_matchmerge)
	keep if _matchmerge == 3
	drop _matchmerge
	* merge in energy for the control guys
	merge m:1 cds_controlmatch date block using "$dirpath_data_temp/control_energy_data.dta", gen(_energymerge)
	keep if _energymerge == 3
	drop _energymerge
	drop evertreat* cds_controlmatch cds_treatmatch
	*create the LHS variable: (T - C)
	gen prediction_error_log_minus_match = prediction_error_log - prediction_error_log_match
	cap drop any_post_treat_*
	
	* reghdfe needs to be regressed on something, hence the ones
	gen ones = 1
	* create the T-C residuals! 
	reghdfe prediction_error_log_minus_match ones, absorb(FE_BLOCK=i.block FE_SCHOOL=i.cds_code FE_MOS=i.month_of_sample) tol(0.001)
	predict resids, residual
	drop FE*
	* code up treatment dates
	egen treatdate_temp = min(date) if any_post_treat == 1, by(cds_code)
	egen treatdate = max(treatdate), by(cds_code)
	drop treatdate_temp
	
	* list the number of days until treatment
	gen days_to_treat = .
	replace days_to_treat = 0 if date == treatdate
	qui forvalues i = 1/365 {
	replace days_to_treat = -`i' if date == treatdate - `i'
	replace days_to_treat = `i' if date == treatdate + `i'
	}
	
	save "$dirpath_data_int/Matching/any_`districttype'_`matchtype'_PREDICT_FOR_REGRESSIONS.dta", replace
  }
}


foreach districttype in ANY EXACT OPPOSITE {
  foreach matchtype in dailyavg blocks overall {
  * main energy dataset
use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
	* merge in for the treated guys
	merge m:1 cds_code using "$dirpath_data_temp/any_`matchtype'_TREATED_`districttype'.dta", gen(_matchmerge)
	keep if _matchmerge == 3
	drop _matchmerge
	* merge in energy for the control guys
	merge m:1 cds_controlmatch date block using "$dirpath_data_temp/control_energy_data.dta", gen(_energymerge)
	keep if _energymerge == 3
	drop _energymerge
	drop evertreat* cds_controlmatch cds_treatmatch
	*create the LHS variable: (T - C)
	gen log_kwh_min_match = log_kwh - log_kwh_match
	cap drop any_post_treat_*
	
	* reghdfe needs to be regressed on something, hence the ones
	gen ones = 1
	* create the T-C residuals! 
	reghdfe log_kwh_min_match ones, absorb(FE_BLOCK=i.block FE_SCHOOL=i.cds_code FE_MOS=i.month_of_sample) tol(0.001)
	predict resids, residual
	drop FE*
	* code up treatment dates
	egen treatdate_temp = min(date) if any_post_treat == 1, by(cds_code)
	egen treatdate = max(treatdate), by(cds_code)
	drop treatdate_temp
	
	* list the number of days until treatment
	gen days_to_treat = .
	replace days_to_treat = 0 if date == treatdate
	qui forvalues i = 1/365 {
	replace days_to_treat = -`i' if date == treatdate - `i'
	replace days_to_treat = `i' if date == treatdate + `i'
	}
	
	save "$dirpath_data_int/Matching/any_`districttype'_`matchtype'_FOR_REGRESSIONS.dta", replace
  }
}
