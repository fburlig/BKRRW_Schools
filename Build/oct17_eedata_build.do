
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
import excel using "$dirpath_data_raw/PGE_Oct_2016/PGE School Meter Matching to UCB 20161017.xlsx", sheet("All_Match EE") clear firstrow
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id application_code - unadj_gross_thm

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
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat") | strpos(technology_family, "REFRIG")
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
drop if install_date == .
* clean install date
* create a numeric install date
gen date_stata = dofc(install_date)
** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

*** GENERATE OVERALL DATES

** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different


** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
duplicates t sp_id measure_code date_stata, gen(dupemeasure)


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
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_part1.dta", replace


******* REPEAT FOR CLUSTERS, AND FOR THE OTHER DATA FILE

* import the csv
import excel using "$dirpath_data_raw/PGE_Oct_2016/PGE School Meter Matching to UCB 20161017.xlsx", sheet("Match_Failed_School_NAICS EE") clear firstrow
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id application_code - unadj_gross_thm

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
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat") | strpos(technology_family, "REFRIG")
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
drop if install_date == .
* clean install date
* create a numeric install date
gen date_stata = dofc(install_date)
** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different


** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
duplicates t sp_id measure_code date_stata, gen(dupemeasure)


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

** only 2 of these? Maybe check with ming.
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_part2.dta", replace



**** repeat for other file

* import the csv
import excel using "$dirpath_data_raw/PGE_Oct_2016/UCB SP for EE 20161017.xlsx", sheet("Sheet 1") clear firstrow
rename *, lower

replace measure_desc = upper(measure_desc)

* get rid of lines without ee upgrades
drop if measure_code == "" & measure_desc == ""
* keep only the variables we need
keep sp_id application_code - unadj_gross_thm

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
replace technology_family = "Refrigeration" if technology_family == "Chiller" | strpos(technology_family, "Refrigerat") | strpos(technology_family, "REFRIG")
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
drop if install_date == .
* clean install date
* create a numeric install date
gen date_stata = dofc(install_date)
** executive decision: annual kwh savings calculated based on ADJUSTED gross savings
* i'll leave the unadj savings in as well just in case

** when application codes span multiple dates, keep only the first date 
** 52/12,542 are dupes like this
egen mindate = min(date_stata), by(sp_id application_code)
gen different = 0
replace different = 1 if date_stata != mindate
drop if different == 1
drop different


** create a flag if there are multiple instances of the same measure recorded 
* for the same date/application id / spid
duplicates t sp_id measure_code date_stata, gen(dupemeasure)
duplicates t sp_id measure_code date_stata application_code, gen(dupemeasure2)


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
save "$dirpath_data_temp/ee_build_dataset_ee_oct17_part3.dta", replace


****** append datasets together
use "$dirpath_data_temp/ee_build_dataset_ee_oct17_part1.dta", clear
append using "$dirpath_data_temp/ee_build_dataset_ee_oct17_part2.dta"
append using "$dirpath_data_temp/ee_build_dataset_ee_oct17_part3.dta"

duplicates t sp_id measure_code date_stata application_code, gen(dupemeasure3)
replace dupemeasure = 0 if dupemeasure == .
duplicates drop

save "$dirpath_data_temp/ee_build_dataset_appended_AUGUST.dta", replace



/*
*** Match additional data on measure codes in
import excel using "$dirpath_data_raw/PGE EE Measures/MeasureExtract_Active_1-29-2016 8-27-11 AM.xlsx", firstrow case(lower) clear
keep measurecode measapptype 
replace measapptype = "ROB" if measapptype == "NC"
duplicates drop
rename measurecode measure_code
save "$dirpath_data_temp/ee_measure_types.dta", replace


use "$dirpath_data_temp/ee_build_dataset_appended_AUGUST.dta", clear
merge m:1 measure_code using "$dirpath_data_temp/ee_measure_types.dta"

*/

