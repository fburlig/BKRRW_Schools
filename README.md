# BKRRW_Schools
This repository contains the code required to replicate Burlig, Knittel, Rapson, Reguant, and Wolfram (2020): "Machine learning from schools about energy efficiency."

Due to a non-disclosure agreement between UC Berkeley and Pacific Gas and Electric, we are unable to release the electricity for this project publicly. Academic researchers wishing to replicate our results can submit a request through the [Energy Data Request Program](https://pge-energydatarequest.com/). 

Upon obtaining data from PG&E, *and putting these data in the data xxxx folder*, researchers can replicate our results by running the code in the following order:

1) `BKRRW_Schools/00_MASTER_set_paths.do` sets all paths for use in subsequent Stata .do files. Before using this, you will need to change the master paths to match your directory structure.

2) `BKRRW_Schools/Build/B00_MASTER_build_all.do` runs all code to build datasets in Stata. Note that some portions of this build are run in `R`. Researchers will have to run the 4 `.R` files in the `BKRRW_Schools/Build` folder at the appropriate time partway through the `BOO_MASTER_build_all.do` file. This code takes large amounts of memory and is quite slow, due to the use of interval electricity metering data.

3) `BKRRW_Schools/Analyze/A00_MASTER_analysis_all.do` runs all analysis code in Stata. 

4) `BKRRW_Schools/PO00_MASTER_produce_output_all.do` generates all tables (in LaTeX format) and figures (in PDF format) in Stata for both the main text and the appendix. Appendix Figure C.1: "Locations of untreated and treated schools" must be built in `R` using the file `jan4_map_tc.R`.

The `BKRRW_Schools/Build`, `BKRRW_Schools/Analyze`, and `BKRRW_Schools/Produce_output` folders contain all required sub-programs. 
