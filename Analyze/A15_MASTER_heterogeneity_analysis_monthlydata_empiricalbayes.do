************************************************
**** ANALYSIS: QUANTILE REGRSSIONS (EMPIRICAL BAYES)
************************************************


{
* create numobs and davis savings
use "$dirpath_data_temp/monthly_by_block10_sample0.dta", clear
sort cds_code month_of_sample block
by cds_code: egen davis_by_school = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
collapse (mean) davis_by_school (sum) numobs, by(cds_code)
replace davis_by_school = -davis_by_school/(24*365)
duplicates drop 
isid cds_code
save "$dirpath_data_temp/davis_by_school.dta", replace
}

{
* main heterogeneity analysis
use "$dirpath_data_int/school_specific_slopes_flagged_robust.dta", clear


* merge in data
merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/davis_by_school.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/demographics_for_selection_regs.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/cds_coastal.dta", keep(3) nogen

* auxiliary variables
gen hvac_dummy = 0
gen light_dummy = 0
gen hvac_light = 0
replace hvac_dummy = 1 if tot_kwh_hvac > 0 & tot_kwh_hvac != .
replace light_dummy = 1 if tot_kwh_light > 0 & tot_kwh_light != .
replace hvac_light = 1 if hvac_dummy == 1 & light_dummy == 1
replace hvac_dummy = 0 if hvac_light==1
replace light_dummy = 0 if hvac_light==1

foreach name in  "hvac_dummy" "light_dummy" "hvac_light" "hvaccoastal"{
   gen b_`name' = .
   gen se_`name' = .
   }
   
* renormalize covariates
foreach name in  "cde_lon" "cde_lat" "temp_f" ///
   "mean_energy_use" "enr_total" "API_BASE" "poverty_rate" "tot_kwh" "coastal"  {
   	qui summ `name'
	replace `name' = (`name'-r(mean))/r(sd)

   gen b_`name' = .
   gen se_`name' = .
   }
 
 
gen ebayes_rel = ebayes_slope / davis_by_school
gen ebayes_rel2 = - ebayes_slope / davis_denominator * (365*24)
replace ebayes_rel2 = . if ebayes_rel == .
 

* prepare things to store
gen b_cons = .
gen se_cons = .

drop nobs spec

gen nobs = .
gen spec = .


**** RUN REGRESSIONS ***
local spec = 3
local s = 0
local beta_pick = "ebayes_rel2"

qreg `beta_pick' 
replace b_cons = _b[_cons] in 1
replace se_cons = _se[_cons] in 1
replace nobs = `e(N)' in 1
replace spec = 1 in 1

qreg `beta_pick' hvac_dummy light_dummy hvac_light 
replace b_cons = _b[_cons] in 2
replace se_cons = _se[_cons] in 2
replace b_hvac_dummy = _b[hvac_dummy] in 2
replace se_hvac_dummy = _se[hvac_dummy] in 2
replace b_light_dummy = _b[light_dummy] in 2
replace se_light_dummy = _se[light_dummy] in 2
replace b_hvac_light = _b[hvac_light] in 2
replace se_hvac_light = _se[hvac_light] in 2
replace nobs = `e(N)' in 2
replace spec = 2 in 2

qreg `beta_pick' hvac_dummy light_dummy hvac_light cde_lon cde_lat coastal temp_f
replace b_cons = _b[_cons] in 3
replace se_cons = _se[_cons] in 3
replace b_hvac_dummy = _b[hvac_dummy] in 3
replace se_hvac_dummy = _se[hvac_dummy] in 3
replace b_light_dummy = _b[light_dummy] in 3
replace se_light_dummy = _se[light_dummy] in 3
replace b_hvac_light = _b[hvac_light] in 3
replace se_hvac_light = _se[hvac_light] in 3
replace b_temp_f = _b[temp_f] in 3
replace se_temp_f = _se[temp_f] in 3
replace b_cde_lon = _b[cde_lon] in 3
replace se_cde_lon = _se[cde_lon] in 3
replace b_cde_lat = _b[cde_lat] in 3
replace se_cde_lat = _se[cde_lat] in 3
replace b_coastal = _b[coastal] in 3
replace se_coastal = _se[coastal] in 3
replace nobs = `e(N)' in 3
replace spec = 3 in 3

qreg `beta_pick' hvac_dummy light_dummy hvac_light cde_lon cde_lat coastal temp_f  enr_total 
replace b_cons = _b[_cons] in 4
replace se_cons = _se[_cons] in 4
replace b_hvac_dummy = _b[hvac_dummy] in 4
replace se_hvac_dummy = _se[hvac_dummy] in 4
replace b_light_dummy = _b[light_dummy] in 4
replace se_light_dummy = _se[light_dummy] in 4
replace b_hvac_light = _b[hvac_light] in 4
replace se_hvac_light = _se[hvac_light] in 4
replace b_temp_f = _b[temp_f] in 4
replace se_temp_f = _se[temp_f] in 4
replace b_cde_lon = _b[cde_lon] in 4
replace se_cde_lon = _se[cde_lon] in 4
replace b_cde_lat = _b[cde_lat] in 4
replace se_cde_lat = _se[cde_lat] in 4
replace b_enr_total = _b[enr_total] in 4
replace se_enr_total = _se[enr_total] in 4
replace b_coastal = _b[coastal] in 4
replace se_coastal = _se[coastal] in 4
replace nobs = `e(N)' in 4
replace spec = 4 in 4

qreg `beta_pick' hvac_dummy light_dummy hvac_light cde_lon cde_lat temp_f coastal enr_total API_BASE poverty_rate  
replace b_cons = _b[_cons] in 5
replace se_cons = _se[_cons] in 5
replace b_hvac_dummy = _b[hvac_dummy] in 5
replace se_hvac_dummy = _se[hvac_dummy] in 5
replace b_light_dummy = _b[light_dummy] in 5
replace se_light_dummy = _se[light_dummy] in 5
replace b_hvac_light = _b[hvac_light] in 5
replace se_hvac_light = _se[hvac_light] in 5
replace b_enr_total = _b[enr_total] in 5
replace se_enr_total = _se[enr_total] in 5
replace b_cde_lon = _b[cde_lon] in 5
replace se_cde_lon = _se[cde_lon] in 5
replace b_cde_lat = _b[cde_lat] in 5
replace se_cde_lat = _se[cde_lat] in 5
replace b_API_BASE = _b[API_BASE] in 5
replace se_API_BASE = _se[API_BASE] in 5
replace b_poverty_rate = _b[poverty_rate] in 5
replace se_poverty_rate = _se[poverty_rate] in 5
replace b_temp_f = _b[temp_f] in 5
replace se_temp_f = _se[temp_f] in 5
replace b_coastal = _b[coastal] in 5
replace se_coastal = _se[coastal] in 5
replace nobs = `e(N)' in 5
replace spec = 5 in 5

qreg `beta_pick' hvac_dummy light_dummy hvac_light cde_lon cde_lat temp_f  enr_total API_BASE poverty_rate tot_kwh coastal 
replace b_cons = _b[_cons] in 6
replace se_cons = _se[_cons] in 6
replace b_hvac_dummy = _b[hvac_dummy] in 6
replace se_hvac_dummy = _se[hvac_dummy] in 6
replace b_light_dummy = _b[light_dummy] in 6
replace se_light_dummy = _se[light_dummy] in 6
replace b_hvac_light = _b[hvac_light] in 6
replace se_hvac_light = _se[hvac_light] in 6
replace b_enr_total = _b[enr_total] in 6
replace se_enr_total = _se[enr_total] in 6
replace b_cde_lon = _b[cde_lon] in 6
replace se_cde_lon = _se[cde_lon] in 6
replace b_cde_lat = _b[cde_lat] in 6
replace se_cde_lat = _se[cde_lat] in 6
replace b_API_BASE = _b[API_BASE] in 6
replace se_API_BASE = _se[API_BASE] in 6
replace b_poverty_rate = _b[poverty_rate] in 6
replace se_poverty_rate = _se[poverty_rate] in 6
replace b_temp_f = _b[temp_f] in 6
replace se_temp_f = _se[temp_f] in 6
replace b_tot_kwh = _b[tot_kwh] in 6
replace se_tot_kwh = _se[tot_kwh] in 6
replace b_coastal = _b[coastal] in 6
replace se_coastal = _se[coastal] in 6
replace nobs = `e(N)' in 6
replace spec = 6 in 6



gen hvac_coastal = hvac_dummy * coastal

qreg `beta_pick' hvac_dummy light_dummy hvac_light cde_lon cde_lat temp_f  enr_total API_BASE poverty_rate tot_kwh coastal hvac_coastal 
replace b_cons = _b[_cons] in 7
replace se_cons = _se[_cons] in 7
replace b_hvac_dummy = _b[hvac_dummy] in 7
replace se_hvac_dummy = _se[hvac_dummy] in 7
replace b_light_dummy = _b[light_dummy] in 7
replace se_light_dummy = _se[light_dummy] in 7
replace b_hvac_light = _b[hvac_light] in 7
replace se_hvac_light = _se[hvac_light] in 7
replace b_enr_total = _b[enr_total] in 7
replace se_enr_total = _se[enr_total] in 7
replace b_cde_lon = _b[cde_lon] in 7
replace se_cde_lon = _se[cde_lon] in 7
replace b_cde_lat = _b[cde_lat] in 7
replace se_cde_lat = _se[cde_lat] in 7
replace b_API_BASE = _b[API_BASE] in 7
replace se_API_BASE = _se[API_BASE] in 7
replace b_poverty_rate = _b[poverty_rate] in 7
replace se_poverty_rate = _se[poverty_rate] in 7
replace b_temp_f = _b[temp_f] in 7
replace se_temp_f = _se[temp_f] in 7
replace b_tot_kwh = _b[tot_kwh] in 7
replace se_tot_kwh = _se[tot_kwh] in 7
replace b_coastal = _b[coastal] in 7
replace se_coastal = _se[coastal] in 7
replace b_hvaccoastal = _b[hvac_coastal] in 7
replace se_hvaccoastal = _se[hvac_coastal] in 7
replace nobs = `e(N)' in 7
replace spec = 7 in 7



keep b_* se_* nobs spec 
duplicates drop

gen yvar = "`beta_pick'"
drop if spec == .

****
save "$dirpath_data_int/MONTHLY_heterogeneity_by_characteristics_EB.dta", replace
}


