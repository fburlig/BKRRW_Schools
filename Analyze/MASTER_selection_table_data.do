************************************************
**** ANALYSIS: SELECTION TABLE
************************************************

** needs to be done AFTER the build files so that we can grab the right datasets
** grab true/randomized treat dates
use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
*append using "$dirpath_data_temp/full_blocks_any_newpred_by_block_post.dta"
keep cds_code date cumul_kwh posttrain
egen treat_date_tc = min(date) if posttrain == 1 | cumul_kwh > 0, by(cds_code)
keep treat_date_tc cds_code
drop if treat_date_tc == .
duplicates drop
gen treat_year_tc = year(treat_date_tc)
save "$dirpath_data_temp/school_treatdates.dta", replace


**** Setup: Grab coordinates
import excel "$dirpath_data_raw/PGE_LEA_match/PGE LEA Meter Matching 20150624.xlsx", sheet("All_Matches") firstrow clear
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


*** grab bond data (at the district level)
import excel using "$dirpath_data_other/Demographics/Approved CA District Facilities Bonds.xlsx", sheet("Original - CA elections thr2014") firstrow clear
gen bond_yn = 0
replace bond_yn = 1 if regexm(Passed, "y")
replace bond_yn = 1 if regexm(Passed, "Y")

gen bond_date = .
replace bond_date = Electiondate if bond_yn == 1
gen election_year = year(Electiondate)
gen bond_year = year(bond_date)

rename Dcode dcode
keep dcode bond_year
sort dcode bond_year
by dcode: gen counter = _n
reshape wide bond_year, i(dcode) j(counter)
save "$dirpath_data_other/Demographics/bond_data.dta", replace

**** Import data:

use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
*append using "$dirpath_data_temp/full_blocks_any_newpred_by_block_post.dta"
collapse(min) date (mean) qkw_hour temp_f *_kwh (median) qkw_median=qkw_hour (p75) qkw_p25=qkw_hour (p25) qkw_p75=qkw_hour, by(cds_code)

* we can only run selection regs on the things we actually have demographics for
merge 1:m cds_code using "$dirpath_data_other/Demographics/schools_comparison_no_weights.dta", gen(_demogmerge1)
drop if _demogmerge1 ==2

merge m:1 county using "$dirpath_data_other/Demographics/data_presidential_county.dta", gen(_presmerge)
drop if _presmerge ==2

merge m:1 cds_code using "$dirpath_data_temp/school_coords.dta", gen (_weathermerge)
drop if _weathermerge == 2


gen stata_open_date = date(opendate,"YMD")
gen school_age = (date("$S_DATE","DMY") - stata_open_date) / 365
gen school_age2 = school_age^2

gen elementary = regexm(soctype,"Elem")
gen middle = regexm(soctype,"Middle") | regexm(soctype,"Junior")
gen high = regexm(soctype,"^High") 
gen k12 = regexm(soctype,"K-12")
gen other = 1 - (elementary + middle + high + k12)

**** COLLAPSE TO GET ONE SCHOOL OBSERVATION
collapse (mean) date qkw_* temp_f *_kwh *merge cde_lat cde_lon median_age_male median_age_female pct_black pct_hispanic pct_AmIndian pct_asian pct_other pct_mixed ///
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
hdd cdd enr_total API_BASE school_age school_age2 elementary middle high k12 students graduates ///
, by(cds_code)

gen ln_enr_total = log(enr_total)

gen year = year(date)

label variable year "First year in sample"
label variable qkw_hour "Hourly energy consumption (kWh)"
label variable temp_f "Temperature (F)"
label variable cde_lat "Latitude"
label variable cde_lon "Longitude"
label variable API_BASE "Academic Performance Index"
label variable enr_total "Total enrollment"
label variable NOT_HSG "Not High School Graduates"
label variable HSG "High School Graduates"
label variable SOME_COL "Some College" 
label variable COL_GRAD "College Graduates"
label variable pct_single_mom "Percent single mothers"
label variable poverty_rate "Poverty Rate"
label variable PCT_AA "Percent African-American"
label variable PCT_AI "Percent Native American"
label variable PCT_AS "Percent Asian"
label variable PCT_FI "Percent Filipino"
label variable PCT_HI "Percent Hispanic"
label variable PCT_PI "Percent Pacific Islander"
label variable PCT_WH "Percent White"
label variable PCT_MR "Percent 2+ races"
label variable elementary "Elementary School"
label variable middle "Middle School"
label variable high "High School"

tostring cds_code, gen(cds_string) format("%14.0f")

gen dcode = substr(cds_string, 3, 5)

merge 1:1 cds_code using "$dirpath_data_temp/school_treatdates.dta", gen(_treatmerge)

merge m:1 dcode using "$dirpath_data_other/Demographics/bond_data.dta", gen(_bondmerge)
drop if _bondmerge == 2
gen bond = 0
replace bond = 1 if _bondmerge == 3
drop _bondmerge

gen closebond_2 = 0
gen closebond_5 = 0

forvalues i = 1/12 {
 replace closebond_2 = 1 if bond_year`i' <= treat_year_tc & bond_year`i' >= treat_year_tc - 2
 replace closebond_5 = 1 if bond_year`i' <= treat_year_tc & bond_year`i' >= treat_year_tc - 5
}

save "$dirpath_data_temp/demographics_for_selection_regs.dta", replace


use "$dirpath_data_temp/demographics_for_selection_regs.dta", clear
merge 1:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", nogen

gen evertreated_h = 0
replace evertreated_h = 1 if tot_kwh_hvac >0 & tot_kwh_hvac !=.

gen evertreated_l = 0
replace evertreated_l = 1 if tot_kwh_light >0 & tot_kwh_light !=.

gen purecontrol = 0
replace purecontrol = 1 if tot_kwh == 0

gen evertreated_any = 0
replace evertreated_any = 1 if tot_kwh >0 & tot_kwh !=.

gen evertreated_hvac_pure = .
replace evertreated_hvac_pure = 0 if purecontrol == 1
replace evertreated_hvac_pure = 1 if evertreated_h == 1

gen evertreated_light_pure = .
replace evertreated_light_pure = 0 if purecontrol == 1
replace evertreated_light_pure = 1 if evertreated_l == 1

merge 1:1 cds_code using "$dirpath_data_int/hvac_light_pure.dta", keep(3) nogen

gen percent_savings = tot_kwh/(24*365*qkw_hour)

summ percent_savings if purecontrol==0, det
summ percent_savings if evertreated_l==1, det
summ percent_savings if evertreated_h==1, det

label var closebond_2 "Bond passed -- 2 yrs"
label var closebond_5 "Bond passed -- 5 yrs"

save "$dirpath_data_int/data_for_selection_table.dta", replace
