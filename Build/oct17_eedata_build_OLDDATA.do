
************************************************
**** MASTER DO FILE TO CONSTRUCT EE UPGRADES DATA
**** WRITTEN BY FIONA BURLIG (fiona.burlig@berkeley.edu)
**** CREATED: August 9, 2016
**** LAST EDITED: August 9, 2016

**** DESCRIPTION: This file builds energy efficiency data
			
**** NOTES: 
	
**** PROGRAMS:

**** CHOICES:
		
************************************************
************************************************
**** SETUP:
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
global dirpath_data_other "$dirpath/Data/Other data"
global dirpath_results_prelim "$dirpath/Results/Preliminary"
************************************************


* import the csv
insheet using "$dirpath_data_raw/PGE_energy_combined/Customer info/EEStats 19844 CUST EE 20150811_csv.csv", clear comma
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id measure_code - unadj_gross_thm

* get rid of audits/tests (not actual upgrades!)

drop if measure_desc == "AUDIT SERVICE CODE"
drop if strpos(measure_desc, "MARKETING")
drop if strpos(measure_desc, "AUDIT")
drop if strpos(measure_desc, "SIGNING")
drop if strpos(measure_desc, "ENERGY EDUCATION")
drop if strpos(measure_desc, "PAYMENT")
drop if measure_desc == "?"
drop if measure_desc == "NGAT TESTING"
drop if measure_desc == "KICKER MEASURE"


* no technology_family missing
  
* define tech fams more broadly - differently coded now

drop if technology_family == "Audit Information Testing Services"
replace technology_family = "Building envelope" if technology_family == "Building Shell (Opaque)"
replace technology_family = "Building envelope" if technology_family == "Building Shell"
replace technology_family = "Electronics and IT" if technology_family == "Business and Consumer Electronics"
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat")
replace technology_family = "Food Service Technology" if technology_family == "Cooking Equipment"
replace technology_family = "HVAC" if strpos(technology_family, "HVAC")
replace technology_family = "Lighting" if strpos(technology_family, "Lighting")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Motor")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool Pump")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool and Spa Equipment")
replace technology_family = "Motors, pumps, fans" if technology_family == "Liquid Circulation"

replace technology_family = "Motors, pumps, fans" if technology_family == "Pumps and Fans"
replace technology_family = "HVAC" if strpos(technology_family, "Heating")
replace technology_family = "HVAC" if strpos(technology_family, "dX AC")  

replace technology_family = "Boilers and Steam Systems" if strpos(technology_family, "Industrial Systems") 



replace technology_family = upper(technology_family)





* get rid of things that don't have a tech family
drop if technology_family == ""
* create a numeric variable for tech fam
encode technology_family, gen(upgrade_tech_fam) 
* get rid of extra variables
*keep sp_id incr_cost - upgrade_tech_fam
* remove upgrades if we don't know when they're installed (can't use). <2% of upgrades.

gen date_stata = date(install_date, "MDYhms")

** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

*** GENERATE OVERALL DATES

/*
** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different
**/

** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
/*
duplicates t sp_id measure_code date_stata, gen(dupemeasure)
*/

** string spid
tostring sp_id, replace
count

* eliminate variables (drops don't matter)
drop install_date unadj*
duplicates drop
drop measure_desc
duplicates drop
drop work_paper_name
duplicates drop

** save
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part1.dta", replace


******* REPEAT FOR CLUSTERS, AND FOR THE OTHER DATA FILE

* import the csv
insheet using "$dirpath_data_raw/PGE_energy_combined/Customer info/CONFIDENTIAL EEStats 19844 CUST EE.csv", comma clear 
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id measure_code - unadj_gross_thm

* get rid of audits/tests (not actual upgrades!)

drop if measure_desc == "AUDIT SERVICE CODE"
drop if strpos(measure_desc, "MARKETING")
drop if strpos(measure_desc, "AUDIT")
drop if strpos(measure_desc, "SIGNING")
drop if strpos(measure_desc, "ENERGY EDUCATION")
drop if strpos(measure_desc, "PAYMENT")
drop if measure_desc == "?"
drop if measure_desc == "NGAT TESTING"
drop if measure_desc == "KICKER MEASURE"


* no technology_family missing
  
* define tech fams more broadly - differently coded now

drop if technology_family == "Audit Information Testing Services"
replace technology_family = "Building Shell" if technology_family == "Building Shell (Opaque)"
replace technology_family = "Electronics and IT" if technology_family == "Business and Consumer Electronics"
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat")
replace technology_family = "Food Service Technology" if technology_family == "Cooking Equipment"
replace technology_family = "HVAC" if strpos(technology_family, "HVAC")
replace technology_family = "Lighting" if strpos(technology_family, "Lighting")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Motor")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool Pump")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool and Spa Equipment")
replace technology_family = "Motors, pumps, fans" if technology_family == "Liquid Circulation"

replace technology_family = "Motors, pumps, fans" if technology_family == "Pumps and Fans"
replace technology_family = "HVAC" if strpos(technology_family, "Heating")
replace technology_family = "HVAC" if strpos(technology_family, "dX AC")  

replace technology_family = "Boilers and Steam Systems" if strpos(technology_family, "Industrial Systems") 
replace technology_family = upper(technology_family)

* get rid of things that don't have a tech family
drop if technology_family == ""
* create a numeric variable for tech fam
encode technology_family, gen(upgrade_tech_fam) 
* get rid of extra variables
*keep sp_id incr_cost - upgrade_tech_fam
* remove upgrades if we don't know when they're installed (can't use). <2% of upgrades.

* clean install date
* create a numeric install date
gen date_stata = date(install_date, "MDY")
drop if date_stata == .
** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

*** GENERATE OVERALL DATES

/*
** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different
**/
/*
** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
duplicates t sp_id measure_code date_stata, gen(dupemeasure)
*/

** string spid
tostring sp_id, replace
count

* eliminate variables (drops don't matter)
drop install_date unadj*
duplicates drop
drop measure_desc
duplicates drop
drop work_paper_name
duplicates drop

** save
** only 2 of these? Maybe check with ming.
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part2.dta", replace



**** repeat for other file

* import the csv
insheet using "$dirpath_data_raw/PGE_energy_combined/Customer info/ucb cust ee 20150306_csv.csv", comma clear 
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id measure_code - unadj_gross_thm

* get rid of audits/tests (not actual upgrades!)

drop if measure_desc == "AUDIT SERVICE CODE"
drop if strpos(measure_desc, "MARKETING")
drop if strpos(measure_desc, "AUDIT")
drop if strpos(measure_desc, "SIGNING")
drop if strpos(measure_desc, "ENERGY EDUCATION")
drop if strpos(measure_desc, "PAYMENT")
drop if measure_desc == "?"
drop if measure_desc == "NGAT TESTING"
drop if measure_desc == "KICKER MEASURE"


* no technology_family missing
  
* define tech fams more broadly - differently coded now

drop if technology_family == "Audit Information Testing Services"
replace technology_family = "Building Shell" if technology_family == "Building Shell (Opaque)"
replace technology_family = "Electronics and IT" if technology_family == "Business and Consumer Electronics"
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat")
replace technology_family = "Food Service Technology" if technology_family == "Cooking Equipment"
replace technology_family = "HVAC" if strpos(technology_family, "HVAC")
replace technology_family = "Lighting" if strpos(technology_family, "Lighting")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Motor")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool Pump")
replace technology_family = "Motors, pumps, fans" if strpos(technology_family, "Pool and Spa Equipment")
replace technology_family = "Motors, pumps, fans" if technology_family == "Liquid Circulation"

replace technology_family = "Motors, pumps, fans" if technology_family == "Pumps and Fans"
replace technology_family = "HVAC" if strpos(technology_family, "Heating")
replace technology_family = "HVAC" if strpos(technology_family, "dX AC")  

replace technology_family = "Boilers and Steam Systems" if strpos(technology_family, "Industrial Systems") 
replace technology_family = upper(technology_family)
* get rid of things that don't have a tech family
drop if technology_family == ""
* create a numeric variable for tech fam
encode technology_family, gen(upgrade_tech_fam) 
* get rid of extra variables
*keep sp_id incr_cost - upgrade_tech_fam
* remove upgrades if we don't know when they're installed (can't use). <2% of upgrades.

gen date_stata = date(install_date, "MDY")
** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

*** GENERATE OVERALL DATES

/*
** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different
**/

/*
** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
duplicates t sp_id measure_code date_stata, gen(dupemeasure)
*/

** string spid
tostring sp_id, replace
count

* eliminate variables (drops don't matter)
drop install_date unadj*
duplicates drop
drop measure_desc
duplicates drop
drop work_paper_name
duplicates drop

** save
** save
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part3.dta", replace


****** append datasets together
use "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part1.dta", clear
append using "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part2.dta"
append using "$dirpath_data_temp/ee_build_dataset_ee_oct17_OLDDATA_part3.dta"
duplicates drop




*** MAR NBER CLEAN


* drop if only date different (and close together)
order date_stata, last
sort sp_id-upgrade_tech_fam date_stata
by sp_id-upgrade_tech_fam: gen obs_except_date = _N
by sp_id-upgrade_tech_fam: gen obs_except_date_count = _n
by sp_id-upgrade_tech_fam: gen diff_time = date_stata[_n]-date_stata[_n-1]
summ obs_except_date if obs_except_date==obs_except_date_count, det
drop if obs_except_date_count > 1 & diff_time < 40
summ obs_except_date if obs_except_date==obs_except_date_count, det
drop obs* diff_time

* drop if only incremental cost coded up differently (e.g., missing)
order incr, last 
sort sp_id-date_stata
by sp_id-date_stata: gen obs_except_incr = _N
by sp_id-date_stata: gen obs_except_incr_count = _n
summ obs_except_incr if obs_except_incr==obs_except_incr_count, det
drop if obs_except_incr_count > 1
drop obs*

* drop if only type of intervention coded up differently
order upgrade_tech_fam, last 
sort sp_id-incr_cost
by sp_id-incr_cost: gen obs_except_techfam = _N
by sp_id-incr_cost: gen obs_except_techfam_count = _n
summ obs_except_techfam if obs_except_techfam==obs_except_techfam_count, det
drop if obs_except_techfam_count > 1
drop obs*

* drop if only adjusted gross kwh coded up differently
order adj_gross_kwh, last
sort sp_id-upgrade_tech_fam adj_gross_kwh
by sp_id-upgrade_tech_fam: gen obs_except_adj = _N
by sp_id-upgrade_tech_fam: gen obs_except_adj_count = _n
summ obs_except_adj if obs_except_adj==obs_except_adj_count, det
drop if obs_except_adj!=obs_except_adj_count
drop obs*

* drop if only incentives cost coded up differently (e.g., missing)
order incentives, last 
sort sp_id-adj_gross_kwh incentives
by sp_id-adj_gross_kwh: gen obs_except_incentives = _N
by sp_id-adj_gross_kwh: gen obs_except_incentives_count = _n
summ obs_except_incentives if obs_except_incentives==obs_except_incentives_count, det
drop if obs_except_incentives_count > 1
drop obs*

* drop if only incentives and adjusted kwh coded up differently (often updated jointly)
sort sp_id-adj_gross_kwh incentives
by sp_id-upgrade_tech_fam: gen obs_except_adj = _N
by sp_id-upgrade_tech_fam: gen obs_except_adj_count = _n
summ obs_except_adj if obs_except_adj==obs_except_adj_count, det
drop if obs_except_adj!=obs_except_adj_count
drop obs*


* drop if only incentives, incr cost and adjusted kwh coded up differently (often updated jointly)
order adj* incr incentives, last
sort sp_id-upgrade_tech_fam adj_gross_kwh
by sp_id-upgrade_tech_fam: gen obs_except_adj = _N
by sp_id-upgrade_tech_fam: gen obs_except_adj_count = _n
summ obs_except_adj if obs_except_adj==obs_except_adj_count, det
drop if obs_except_adj!=obs_except_adj_count
drop obs*


count

* more extreme clean up (one line per measure per school per date)
sort sp_id-product_name date_stata adj_gross_kwh
by sp_id-product_name date_stata: drop if _n != _N
count


order sp_id date_stata measure_code units project_life incentives incr_cost adj_gross_kw adj_gross_kwh adj_gross_thm ///
	technology_family upgrade_tech_fam technology product_name
sort sp_id date_stata measure_code units


gen year = year(date_stata)
keep if year < 2010 & year !=.
drop year

foreach var of varlist units-adj_gross_thm {

 cap replace `var' = subinstr(`var', ",", "", .)
 cap destring `var', replace
}


duplicates t sp_id measure_code date_stata, gen(dupemeasure)
replace dupemeasure = 0 if dupemeasure == .
duplicates drop


save "$dirpath_data_temp/ee_build_dataset_appended_AUGUST_OLDDATA.dta", replace



