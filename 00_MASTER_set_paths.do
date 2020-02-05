************************************************
**** MASTER SETUP
************************************************

************************************************
**** SETUP:
clear all
set more off, perm
set type double
version 12

set seed 12345
global sample 0

** CHANGE TO YOUR DIRECTORY PATH
global dirpath "T:/Projects/Schools"
global dirpath_code "T:/Home/Fiona/backup/BKRRW_Schools.git"

** Code paths
global dirpath_code_build "$dirpath_code/Build"
global dirpath_code_analyze "$dirpath_code/Analyze"

** Data paths
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"
global dirpath_data_other "$dirpath/Data/Other data"

** Results paths
global dirpath_results_prelim "$dirpath/Results/Preliminary"
global dirpath_results_final "$dirpath/Results/Final"

************************************************

************************************************
** Required programs:
/*
 -- unique
 -- geonear
 -- gsort
 -- reghdfe

*/
************************************************
