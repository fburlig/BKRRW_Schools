# BKRRW_Schools
This repository contains the code required to replicate Burlig, Knittel, Rapson, Reguant, and Wolfram (2020): "Machine learning from schools about energy efficiency," conditionally accepted at the _Journal of the Association of Environmental and Resource Economists_. The main text of the paper can be found in [`BKRRW_Schools.pdf`](https://github.com/fburlig/BKRRW_Schools/blob/master/BKRRW_Schools.pdf), and the online appendix can be found in [`BKRRW_Schools_OnlineAppendix.pdf]`(https://github.com/fburlig/BKRRW_Schools/blob/master/BKRRW_Schools_OnlineAppendix.pdf).


### Required data and file structure
Due to a non-disclosure agreement between UC Berkeley and Pacific Gas and Electric (PG&E), we are unable to release the electricity data for this project publicly. Academic researchers wishing to replicate our results can submit a request through the [Energy Data Request Program](https://pge-energydatarequest.com/). Our data request can be found in this repository in [`BKRRW_PGE_data_request.pdf`](https://github.com/fburlig/BKRRW_Schools/blob/master/BKRRW_PGE_data_request.pdf).

The file structure for this project is as follows:
```
MAIN PROJECT FOLDER
|-- Code
|   |-- Analyze
|   |-- Build
|   |-- Produce_output
|-- Data
|   |-- Intermediate
|       |--  School specific
|                    |-- forest
|                    |-- double lasso
|                    |-- prediction
|       |--  Matching
|   |-- Other data
|       |--  CA school info
|       |--  SunriseSunsetHoliday
|       |--  MesoWest FINAL
|   |-- Raw
|       |-- PGE_energy_combined
|                    |-- Customer info
|                    |-- Unzipped electric 15 min
|                    |-- Unzipped electric 60 min
|       |--  PGE_Oct_2016
|   |-- Temp
|-- Results
|   |-- Appendix
```

The full project data folder structure is available at the _JAERE_ website (we will update this Readme with a link when the data are available online), including the fully-populated `Other data` folder. All other folders are empty, per our NDA with PG&E. In order to run the code described below, researchers will need to acquire the following datasets, and place them according to the below filepaths:
 - Meter lat/longs (gas and electric): `[MASTER PROJECT FOLDER]/Data/Raw/`
 - Customer information data: `[MASTER PROJECT FOLDER]/Data/Raw/PGE_energy_combined/Customer info/`
 - Fifteen-minute-interval AMI data:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_energy_combined/Unzipped electric 15 min/`
 - Sixty-minute-interval AMI data:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_energy_combined/Unzipped electric 15 min/`
 - Fifteen-minute-interval AMI data:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_energy_combined/Unzipped electric 15 min/`
 - Matches between schools and meters:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_Oct_2016/`
 - Energy efficiency measure data:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_Oct_2016/`
 - Energy efficiency measure data, pull 2:  `[MASTER PROJECT FOLDER]/Data/Raw/PGE_PGE_energy_combined/Customer info/`


### Code
Upon obtaining data from PG&E, and populating as per the above file structure, researchers can replicate our results by running the code in the following order:

1) `BKRRW_Schools/00_MASTER_set_paths.do` sets all paths for use in subsequent `Stata` .do files. Before using this, you will need to change the master paths to match your directory structure.

2) `BKRRW_Schools/Build/B00_MASTER_build_all.do` runs all code to build datasets in `Stata`. Note that some portions of this build are run in `R`. Researchers will have to run the 4 `.R` files in the `BKRRW_Schools/Build` folder at the appropriate time partway through the `BOO_MASTER_build_all.do` file. This code takes large amounts of memory and is quite slow (ie, may take several days to run), due to the use of interval electricity metering data.

3) `BKRRW_Schools/Analyze/A00_MASTER_analyze_all.do` runs all analysis code in Stata. 

4) `BKRRW_Schools/produce_output/PO00_MASTER_produce_output_all.do` generates all tables (in LaTeX format) and figures (in PDF format) in Stata for both the main text and the appendix. Appendix Figure C.1: "Locations of untreated and treated schools" must be built in `R` using the file `PO05_MASTER_make_map.R`.

The `BKRRW_Schools/Build`, `BKRRW_Schools/Analyze`, and `BKRRW_Schools/Produce_output` folders contain all required sub-programs. 

### Contact
If you have remaining questions about the code described here, please contact [Fiona Burlig](mailto:burlig@uchicago.edu) or [Mar Reguant](mar.reguant@northwestern.edu).
