************************************************
**** PREP TREATMENT VARIABLES 
************************************************

***** HOURLY DATA
use "$dirpath_data_int/MASTER_school_clean_merge.dta", clear
drop year zeroflag problematic month month_of_sample school_id

*** IMPORT CLIMATE ZONE
merge m:1 cds_code using "$dirpath_data_other/Demographics/cds_county_distr_forOFFLINE.dta", gen(_mschoolchar)
drop if _mschoolchar == 2
drop _mschoolchar
rename zip zipcode
merge m:1 zipcode using "$dirpath_data_other/Demographics/zip_to_climatezone.dta", gen(_mzipzone)
drop if _mzipzone == 2
drop _mzipzone district county zipcode

*** MERGE IN UPGRADE DATA
merge m:1 cds_code date using "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", nogen

*** CREATE CUMULATIVE UPGRADE COUNTER
sort cds_code date block
by cds_code: carryforward upgr_counter_all upgr_counter_hvac upgr_counter_light, replace
replace upgr_counter_all = 0 if upgr_counter_all == .
replace upgr_counter_hvac = 0 if upgr_counter_hvac == .
replace upgr_counter_light = 0 if upgr_counter_light == .

gen month = month(date)

gen hvacpure_post_treat = .
replace hvacpure_post_treat = 0 if tot_kwh == 0
replace hvacpure_post_treat = 1 if cumul_kwh_hvac > 0 & cumul_kwh_hvac != . & cumul_kwh==cumul_kwh_hvac

gen lightpure_post_treat = .
replace lightpure_post_treat = 0 if tot_kwh == 0
replace lightpure_post_treat = 1 if cumul_kwh_light > 0 & cumul_kwh_light != . & cumul_kwh==cumul_kwh_light

compress

*** MERGE IN SIZE QUANTILES
preserve
   keep if any_post_treat == 0
   collapse(mean) qkw_hour, by(cds_code)
   rename qkw_hour mean_energy_use
   sum mean_energy_use, detail
   local pctile_25 = r(p25)
   local pctile_50 = r(p50)
   local pctile_75 = r(p75)
   
   gen kwh_quantile = .
   replace kwh_quantile = 1 if mean_energy_use >= 0 & mean_energy_use < `pctile_25'
   replace kwh_quantile = 2 if mean_energy_use >= `pctile_25' & mean_energy_use < `pctile_50'
   replace kwh_quantile = 3 if mean_energy_use >= `pctile_50' & mean_energy_use < `pctile_75'
   replace kwh_quantile = 4 if mean_energy_use >= `pctile_75' & mean_energy_use !=.   
   
   compress
   save "$dirpath_data_temp/mean_energy_use.dta", replace
restore

merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen

keep date block cds_code qkw_hour temp_f tot_kwh cumul_kwh upgr_counter_all ///
	cumul_kwh_hvac upgr_counter_hvac cumul_kwh_light upgr_counter_light ///
	any_post_treat
compress
save "$dirpath_data_int/full_analysis_data_trimmed.dta", replace
