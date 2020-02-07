************************************************
**** MASTER ANALYSIS FILE (CALLS ALL ANALYSIS FILES)
************************************************

******* TAKING STOCK. CURRENTLY MISSING:
-- CODE TO PRODUCE BOOTSTRAPPED STANDARD ERRORS (ONLY THE TABLE)

-- CHECKS ON A FEW UPDATES

-- COULD STREAMLINE SOME OF THESE

************************************************
** ANALYSIS FILES -- TABLES:
{
do "$dirpath_code_analysis/MASTER_selection_table_data.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_temperature.do"
do "$dirpath_code_analysis/MASTER_empirical_bayes_singletons_cluster.do"
do "$dirpath_code_analysis/MASTER_heterogeneity_analysis_monthlydata_empiricalbayes.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_bootstrap.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_matching.do"
do "$dirpath_code_analysis/MASTER_main_predictions_r2.do"
do "$dirpath_code_analysis/MASTER_monthly_regressions_bonds.do"
do "$dirpath_code_analysis/MASTER_monthly_regressions_donuts.do"
do "$dirpath_code_analysis/MASTER_monthly_regressions_savings_donuts.do"
do "$dirpath_code_analysis/MASTER_main_hourly_regressions_noT_saving_jaere.do"
do "$dirpath_code_analysis/MASTER_main_hourly_regressions_temperature_saving_jaere.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_collapses.do"

** Table 1: Average characteristics of schools in the sample
{
do "$dirpath_code_analysis/MASTER_selection_table_data.do"

/*
* inputs: 
 -- "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta"
 -- "$dirpath_data_raw/PGE_LEA_match/PGE LEA Meter Matching 20150624.xlsx"
 -- "$dirpath_data_other/Demographics/Approved CA District Facilities Bonds.xlsx"
 -- "$dirpath_data_other/Demographics/schools_comparison_no_weights.dta"
 -- "$dirpath_data_other/Demographics/data_presidential_county.dta"
 -- "$dirpath_data_temp/school_treatdates.dta"
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_int/hvac_light_pure.dta" 

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
 -- "$dirpath_data_int/School specific/schoolid_cdscode_map.dta"

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


** Table B.1: Panel FE (Alternative SEs)
{
// Main monthly estimates with MOS SE
do "$dirpath_code_analysis/MASTER_monthly_regressions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly.dta"

// [CURRENTLY MISSING BOOTSTRAPPED STANDARD ERRORS]
// [THESE CAN BE GENERATED USING "$dirpath_code_analysis/MASTER_main_monthly_regressions_bootstrap.do"]

// Average program estimates, monthly temperature
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_temperature.do"

/*
* inputs: 
 -- "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
 -- "$dirpath_data_int/school_weather_MASTER_monthly.dta"

* outputs: "$dirpath_data_int/RESULTS_monthly_wtemperature.dta"
*/

* FINAL TABLE SAVED IN: "$dirpath_results_final/Appendix/tab_aggregate_regressions_2wayclus_binary.tex"  

}



** Table B.2: Panel fixed effects results (average school specific estimates; outliers)
{
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

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_reguant_samples.tex"  
}

** Table B.3: Matching results
{
// Matching regressions
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_matching.do"

* inputs: "$dirpath_data_int/Matching/any_`districttype'_`matchtype'_FOR_REGRESSIONS_monthly.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_matching.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/Appendix/tab_matching_any_binary.tex"
}

** Table B.4: R^2s of prediction models across ML methods
{
// ML R^2s
do "$dirpath_code_analysis/MASTER_main_predictions_r2.do"

/*
* inputs: 
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta" 
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta"
* outputs: "$dirpath_data_int/varied_ml_methods_r2_post.dta"
*/
* FINAL TABLE SAVED IN "$dirpath_results_final/tab_mlmethods_r2.tex"
}


** Table B.5: ML (Alternative SEs)
{
// Main monthly estimates with MOS SE]
do "$dirpath_code_analysis/MASTER_monthly_regressions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly.dta"


// [CURRENTLY MISSING BOOTSTRAPPED STANDARD ERRORS]
// [THESE CAN BE GENERATED USING "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"]


* FINAL TABLE SAVED IN: "$dirpath_results_final/Appendix/tab_aggregate_predictions_2wayclus_binary.tex"  
}


** Table B.6: Machine learning effects (average school specific estimates; outliers)
{
// Average school-specific estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"


* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_reguant_samples.tex"  
}


** Table B.7: Machine learning effects (alternative prediction methods)
{
// Average program estimates
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_allml_models.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/Appendix/tab_aggregate_predictions_binary_davis_allml.tex"  
}


** Table B.8: Effects of bond measures on energy use in untreated schools
{
// Estimate DD regressions of bonds in untreated schools
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_BONDS.do"

/*
* inputs:
 -- "$dirpath_data_other/Demographics/Approved CA District Facilities Bonds.xlsx"
 -- "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta"
*/

* outputs: "$dirpath_data_int/RESULTS_monthly_BONDS.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_bonds.tex"
}

** Table B.9: Panel fixed effects results (donuts)
{
// Estimate monthly regressions with donut month drops around treatment
do "$dirpath_code_analysis/MASTER_monthly_regressions_donuts.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_DONUTS.dta"

// Estimate monthly school-specific regressions with donut month drops around treatment
do "$dirpath_code_analysis/MASTER_monthly_regressions_savings_donuts.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_savings_DONUTS.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_DONUTS.tex"
}

** Table B.10: Machine learning results (donuts)
{
// Estimate monthly regressions with donut month drops around treatment
do "$dirpath_code_analysis/MASTER_monthly_regressions_donuts.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_DONUTS.dta"

// Estimate monthly school-specific regressions with donut month drops around treatment
do "$dirpath_code_analysis/MASTER_monthly_regressions_savings_donuts.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_savings_DONUTS.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_DONUTS.tex"
}


** Table B.11: Panel fixed effects results (continuous treatment variable)
{
// Estimate monthly regressions
do "$dirpath_code_analysis/MASTER_monthly_regressions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly.dta"

// Estimate monthly school-specific regressions
do "$dirpath_code_analysis/MASTER_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_continuous_davis_reguant.tex"
}

** Table B.12: Machine learning results (continuous treatment variable)
{
// Estimate monthly regressions
do "$dirpath_code_analysis/MASTER_monthly_regressions.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly.dta"

// Estimate monthly school-specific regressions
do "$dirpath_code_analysis/MASTER_monthly_regressions_savings.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_savings.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_continuous_davis_reguant.tex"
}


** Table B.13; B.14 (PFE results + PFE samples, all monthly) are REDUNDANT and will replace Tables 2 and 3

** Table B.15 Panel fixed effects results (all hourly)
{
// Main hourly estimates (has both average and school-specific)
do "$dirpath_code_analysis/MASTER_main_hourly_regressions_noT_saving_jaere.do"

/*
* inputs: 
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta"
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta"
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"
 
* outputs: "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta"
*/

// Hourly estimates with temperature (has both average and school-specific)
do "$dirpath_code_analysis/MASTER_main_hourly_regressions_temperature_saving_jaere.do"

/*
* inputs: 
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta"
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta"
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"

 * outputs: "$dirpath_data_int/RESULTS_hourly_withtemp_wsavings.dta"
*/
* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_allhourly.tex"
}


** Table B.16 Machine learning results (all hourly)
{
// Main hourly estimates (has both average and school-specific)
do "$dirpath_code_analysis/MASTER_main_hourly_regressions_noT_saving_jaere.do"

/*
* inputs: 
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta"
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta"
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"
 
* outputs: "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta"
*/

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_allhourly.tex"
}

** Table B.17; B.18 (heterogeneity -- EB; selection + coastal) are REDUNDANT and will replace Tables 6 and 1


** Table B.19;B.20 Panel fixed effects/ML (bond heterogeneity) -- REMOVE: NOT NECESSARY FOR REPLIES

** Table B.21 Panel fixed effects (year collapse) -- REMOVE: NOT NECESSARY FOR REPLIES

** Table B.22 Panel fixed effects (month collapse)
{
// Estimate results with data collapsed to the month-of-sample level
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_collapses.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_additional_collapses.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_monthcollapse.tex"
}

** Table B.23 Machine learning (year collapse) -- REMOVE: NOT NECESSARY FOR REPLIES

** Table B.24 Machine learning (month collapse)
{
// Estimate results with data collapsed to the month-of-sample level
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_collapses.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_additional_collapses.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_monthcollapse.tex"
}

** Table B.25 Machine learning results (double LASSO)
{
// Estimate results with data collapsed to the month-of-sample level
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_doublelasso.do"

* inputs: "$dirpath_data_temp/monthly_by_block`b'_sample`subsample'.dta
* outputs: "$dirpath_data_int/RESULTS_monthly_doublelasso.dta"

* FINAL TABLE SAVED IN: "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_doublelasso.tex"
}
}



************************************************
** ANALYSIS FILES -- FIGURES:
{
do "$dirpath_code_analysis/MASTER_main_demographic_regressions_event.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_allpredictions.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_temperature.do"
do "$dirpath_code_analysis/MASTER_empirical_bayes_singletons_cluster.do"
do "$dirpath_code_analysis/MASTER_mlestimators_levels_samples.do"
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_hourly.do"


** Figure 1: Locations of untreated and treated schools
{
// No do-file required to produce results; self-contained within: "$dirpath_code_produceoutput/jan4_map_tc.R"

/*
* inputs:
 -- "$dirpath_data/Other data/Utility Map/cb_2015_us_state_5m.shp"
 -- "$dirpath_data/Other data/Utility Map/CA_Electric_Investor_Owned_Utilities_IOUs.shp"
 -- "$dirpath_data/Other data/Utility Map/utility_map_fromstata.dta" [WHERE DOES THIS COME FROM?]
* outputs: N/A
*/

/*
* FINAL FIGURES SAVED IN: 
 -- "$dirpath_results_final/utilitymap_conly.pdf"
 -- "$dirpath_results_final/utilitymap_tonly.pdf"
 */
}

** Figure 2: School characteristics before and after treatment
{
// Demographic event studies
do "$dirpath_code_analysis/MASTER_main_demographic_regressions_event.do"
* inputs: 
 -- "$dirpath_data_temp/monthly_by_block0_sample0.dta"
 -- "$dirpath_data/Other data/CA school info/ca_school_data.dta" [WHERE DOES THIS DTA COME FROM]

* outputs: "$dirpath_data_int/RESULTS_demographic_eventstudies.dta"

// Energy event study
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_event_yearly_BP.do"
* inputs: "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_eventstudies_yearly_BP.dta"

/*
* FINAL FIGURES SAVED IN:
 -- "$dirpath_results_final/fig_eventstudy_demographics_enrtotal_BP.pdf"
 -- "$dirpath_results_final/fig_eventstudy_demographics_stafftotal_BP.pdf"
 -- "$dirpath_results_final/fig_eventstudy_demographics_mathproficient_BP.pdf"
 -- "$dirpath_results_final/fig_eventstudy_demographics_elaproficient_BP.pdf"
 -- "$dirpath_results_final/Appendix/fig_eventstudy_allspecs_dd_levels_BP.pdf"
*/
}


** Figure 3: Machine learning approach -- graphical intuition
{
// No standalone do-file required to produce results.

* inputs: N/A
* outputs: N/A

* FINAL FIGURES SAVED IN: "$dirpath_results_final/fake_ml_intuition_paper.pdf"
}

** Figure 4: Machine learning diagnostics
{
// No standalone do-file required to produce results.

/*
*inputs: 
 -- "$dirpath_data_int/schools_predictions_by_block.dta" 
 -- "$dirpath_data_int/schools_prediction_variables.dta" 
 -- "$dirpath_data_int/School specific/schoolid_cdscode_map.dta"
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta"
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta"
 
* outputs: N/A
 
* FINAL FIGURES SAVED IN:
 -- "$dirpath_results_final/fig_ml_diagnostics_a.pdf"
 -- "$dirpath_results_final/fig_ml_diagnostics_b.pdf"
 -- "$dirpath_results_final/fig_ml_diagnostics_c.pdf"
 -- "$dirpath_results_final/fig_ml_diagnostics_d.pdf"
*/
}

** Figure 5: Comparison of methods across specifications and samples
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

* FINAL FIGURE SAVED IN: "$dirpath_results_final/fig_kdensities_betas_monthlyt.pdf"
}

** Figure 6: School-specific effects
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

/*
* other inputs:
 -- "$dirpath_data_int/ee_total_formerge.dta"
 -- "$dirpath_data_temp/mean_energy_use.dta"
 -- "$dirpath_data_int/School specific/cdscode_samplesize.dta" [WHERE DO I COME FROM?]
 -- "$dirpath_data_temp/demographics_for_selection_regs.dta" [WHERE DO I COME FROM?]
 */
 
* FINAL FIGURE SAVED IN: "$dirpath_results_final/fig_school_specific_EB.pdf"
}

** Figure A.1: Comparing machine learning estimators
{
// Compute treatment effects with different groups of ML observations
do "$dirpath_code_analysis/MASTER_mlestimators_levels_samples.do"

/*
* inputs:
 -- "$dirpath_data_temp/newpred_formerge_by_block.dta" [HAS THIS GOTTEN UPDATED?]
 -- "$dirpath_data_int/full_analysis_data_trimmed.dta" [HAS THIS GOTTEN UPDATED?]
*/

* outputs: "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta"

* FINAL FIGURE SAVED IN: "$dirpath_results_final/fig_ml_estimators_levels.pdf"
}

** Figure B.2: Machine learning results by hour (alternative prediction methods)
{
// Hour-specific ML regressions
do "$dirpath_code_analysis/MASTER_main_monthly_regressions_hourly.do"

* inputs: "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta"
* outputs: "$dirpath_data_int/RESULTS_monthly_block.dta"

* FINAL FIGURE SAVED IN: "$dirpath_results_final/Appendix/fig_blockwise_ml_levels_binary_mlalternatives_spec`s'.pdf"
}

** Figure B.3 is REDUNDANT (will be replaced by the updated Figure 5)

** Figure B.4: Energy efficiency upgrades
{
// No standalone do-files required

* inputs: "$dirpath_data_int/ee_clean_elec_noclusters.dta"
* outputs: N/A

/*
* FINAL FIGURES SAVED IN:
 -- "$dirpath_results_final/fig_eestats_A.pdf"
 -- "$dirpath_results_final/fig_eestats_B.pdf"
*/
}

** Figure B.5 is REDUNDANT (replaced by A.1)
}
