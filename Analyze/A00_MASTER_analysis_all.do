************************************************
**** MASTER ANALYSIS FILE (CALLS ALL ANALYSIS FILES)
************************************************

** Table 1: Average characteristics of schools in the sample
{
do "$dirpath_code_analysis/Jul15_Selection"

/*
* inputs: 
 -- "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta"
 -- "$dirpath_data_raw/PGE_LEA_match/PGE LEA Meter Matching 20150624.xlsx"
 -- "$dirpath_data_other/Demographics/Approved CA District Facilities Bonds.xlsx"
 -- "$dirpath_data_other/Demographics/schools_comparison_no_weights.dta" [WHERE DOES THIS COME FROM?]
 -- "$dirpath_data_other/Demographics/data_presidential_county.dta" [WHERE DOES THIS COME FROM?]
 -- "$dirpath_data_temp/school_treatdates.dta" [WHERE DOES THIS COME FROM?]
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_int/hvac_light_pure.dta" [NEED TO BRING BACK THIS DO FILE]

* outputs:
 -- "$dirpath_data_int/data_for_selection_table.dta"

* table 1 also requires:
 -- "$dirpath_data_temp/monthly_by_block4_sample0.dta"
 -- "$dirpath_data_temp/cds_coastal.dta"

FINAL TABLE SAVED IN: "$dirpath_results_final/tab_sum_stats_selection_coastal.tex"  
*/
}



** Table 2: Panel fixed effects results
{
// Average program estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_allml_models.dta"

// Average school-specific estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"

// Average program estimates + school-specific estimates, monthly temperature
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_temperature.do"

/*
* inputs: 
 -- "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
 -- "$dirpath_data_int/school_weather_MASTER_monthly.dta"

* outputs: "$dirpath_data_int/RESULTS_monthly_wtemperature.dta"
*/

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_monthlyt.tex"  
}

** Table 3: Panel fixed effects results, samples
{
// Average program estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_allml_models.dta"

// Average program estimates + school-specific estimates, monthly temperature
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_temperature.do"

/*
* inputs: 
 -- "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
 -- "$dirpath_data_int/school_weather_MASTER_monthly.dta"

* outputs: "$dirpath_data_int/RESULTS_monthly_wtemperature.dta"
*/

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_davis_samples_monthlyt.tex"  
}

** Table 4: Machine learning results
{
// Average program estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_allml_models.dta"

// Average school-specific estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis.tex"
}

** Table 5: Machine learning results, samples
{
// Average program estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_allml_models.dta"

// Average school-specific estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis_samples.tex"
}

** Table 6: Predicting heterogeneous results
{
// generate Empirical Bayes shrinkage estimates for all schools
do "$dirpath_code_analysis/MASTER_empirical_bayes_singletons_cluster.do"

/*
* inputs: 
 -- "$dirpath_data_temp/monthly_by_block4_sample0.dta" [UPDATE ME!!! WE DON'T WANT THIS IN THERE]
 -- "$dirpath_data_temp/monthly_by_block10_sample0.dta" [UPDATE ME!!! WE ONLY WANT THIS]
 -- "$dirpath_data_int/School specific/schoolid_cdscode_map.dta" [WHERE DO I COME FROM?]

* outputs:
 -- "$dirpath_data_int/school_specific_slopes_flagged_robust.dta"
*/

// Run quantile regressions
do "$dirpath_code_analysis/MASTER_heterogeneity_analysis_monthlydata_empiricalbayes.do"

/*
* inputs:
 -- "$dirpath_data_temp/monthly_by_block4_sample0.dta" [UPDATE ME! WE DON'T WANT THIS]
 -- "$dirpath_data_temp/monthly_by_block10_sample0.dta" [UPDATE ME! WE ONLY WANT THIS]
 -- "$dirpath_data_int/school_specific_slopes_flagged_robust.dta"

 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"
 -- "$dirpath_data_temp/demographics_for_selection_regs.dta"
 -- "$dirpath_data_temp/cds_coastal.dta"

* outputs:
 -- "$dirpath_data_int/MONTHLY_heterogeneity_by_characteristics_EB.dta"
*/

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_heterogeneity_eb.tex"
}

