
********************************************************************************
** Key steps in preparation of analysis file (ovca2.dta)
********************************************************************************

** Epithelial ovarian cancer cases, adults (18+ years), 1970-2022
 
use "ovary_2022.dta", clear 

keep if ( S_invasivTumor == 1 ) 		// invasive epithelial ovarian tumour 

** Invasive tumour number since 1970 
bysort personlopenr (S_diagnosedato SXmorfologiIcdo3_5 sykdomstilfellenr): gen tnr = _n

keep if ( inrange(year, 2013, 2022) )


********************************************************************************
** Define histotype by morphology ICD03 codes
********************************************************************************

do "histotype.do" 


********************************************************************************
** Labels for pre-defined variables 
********************************************************************************

** Surgical status 

lab def opr_lab 											///
	0 	"Not operated"										///
	1 	"Cytoreductive surgery"
lab val opr opr_lab 


** Residual disease status 

lab def rd_lab 												///
	1	"No residual disease" 								/// 
	2	"Residual disease"									///
	99 	"Unknown"
lab val rd rd_lab 
lab var rd		"Residual disease status"

lab var rdcm	"Residual disease diameter (cm)" 


** Tumour localization 
lab def topography_lab										///
	1	"Peritoneum (C48.2)"								///
	2	"Ovary (C56)"										///
	3	"Tube (C57.0)"										///
	99	"Unknown"
lab val topography topography_lab	


** Stage 
lab def figo_lab 		 									///
	1 	"I"													///
	2 	"II"												///
	3 	"III"												///
	4 	"IV"												///
	99	"Unknown"
lab val figo figo_lab 


** Age group 
recode age  												///
	( 18/39 = 1 "< 40" )									///
	( 40/49 = 2 "40-49" )									///
	( 50/59 = 2 "40-49" )									///
	( 60/69 = 2 "40-49" )									///
	( 70/79 = 2 "40-49" )									///
	( 80/89 = 2 "40-49" )									///
	, gen(agegroup)
			
			
** Year of diagnosis 
recode year 												///
	( 2012/2015 = 1 "2012-2015" )							///
	( 2016/2018 = 2 "2016-2018" )							///
	( 2019/2022 = 3 "2019-2022" )							///
	, gen(period)

	
** Residential health region 
lab def region_lab											///
	100 "South-East" 										///
	1100 "West" 											///
	1500 "Mid" 												///
	1800 "North" 									
lab val region region_lab 	

			
** ECOG performance status  			
lab def ecog_lab 											///
	0 	"Fully active" 										///
	1 	"Restricted strenuous physical activity" 			///
	2 	"Full self-care. Not able to work / 0-50% bed rest" ///
	3 	"Limited self-care"									///
	4 	"Completely disabled" 								///
	99	"Unknown" 
lab val ecog ecog_lab


** Number of co-morbidities 
lab def comorbidity_lab 									///
	0 "None"												///
	1 "One"													///
	2 "Two"													///
	3 "Three or more" 										/// 
	99 "Unknown"
lab val comorbidity comorbidity_lab 


********************************************************************************
** Chemotherapy variables, available 2019-2022 (except North-Norway)
********************************************************************************

** Type of chemotherapy
lab def ct_lab 												///								
	0 	"None" 												///
	1 	"Neoadjuvant only" 									///
	2 	"Neoadjuvant and adjuvant" 							///
	3 	"Adjuvant only"	 									/// 
	4 	"Chemotherapy, not operated" 						///
	99 	"Unknown"											///
	, modify
lab val ct ct_lab 
	

** Neoadjuvant chemotherapy regimen
lab def ct_regimenNeo_lab 									///
	1 	"Platinum-based + Taxane" 							///
	2 	"Platinum-based + Taxane + Bevacizumab"
lab val ct_regimenNeo ct_regimenNeo_lab 


** Neoadjuvant chemotherapy cycles
lab def ct_cyclesNeo_lab 									///
	1	"1-3 cycles"										///
	2	"4-6 cycles"
lab val ct_cyclesNeo ct_cyclesNeo_lab


** Adjuvant Bevacizumab or PARP-inhibitor
lab def ct_maintenanceAdj_lab 								///
	0	"Neither"											///
	1	"Bevacizumab"										///
	2	"PARP-inhibitor"									///
	3	"Both"
lab val ct_maintenanceAdj ct_maintenanceAdj_lab


********************************************************************************
** Indicator variables for regression models  			
********************************************************************************

** Histotype
gen h1 = ( histotype == 1 )
gen h2 = ( histotype == 2 )
gen h3 = ( histotype == 3 )
gen h4 = ( histotype == 4 )
gen h5 = ( histotype == 5 )


** Histotype # residual disease				

* High-grade serous
gen hgs0 = ( histotype == 1 ) & ( rd == 1 )
gen hgs1 = ( histotype == 1 ) & ( rd == 2 )

* Low-grade serous
gen lgs0 = ( histotype == 2 ) & ( rd == 1 )
gen lgs1 = ( histotype == 2 ) & ( rd == 2 )

* Carcinosarcoma
gen car0 = ( histotype == 3 ) & ( rd == 1 )
gen car1 = ( histotype == 3 ) & ( rd == 2 )

* Mucinous
gen muc0 = ( histotype == 4 ) & ( rd == 1 )
gen muc1 = ( histotype == 4 ) & ( rd == 2 )

* Clear cell
gen cc0 =  ( histotype == 5 ) & ( rd == 1 )
gen cc1 =  ( histotype == 5 ) & ( rd == 2 )


** Histotype groups for baseline hazard based on previous work (Fortner 2023)			

* High-grade serous, Carcinosarcoma
gen bhaz1 = ( inlist(histotype, 1, 3 ) )

* Low-grade serous, endometroid
gen bhaz2 = ( inlist(histotype, 2, 6 ) )

* Mucinous, Clear cell
gen bhaz3 = ( inlist(histotype, 4, 5 ) )	

* Adenocarcinoma low/unknown grade, Other epithelial
gen bhaz4 = ( inlist(histotype, 7, 8 ) )


********************************************************************************
** Study population
********************************************************************************

** Target population - first invasive EOC, III/IV, <90 years

gen targetpop = 1
replace targetpop = 0 if ( tnr > 1 ) 					// secondary tumour
replace targetpop = 0 if ( age >= 90 ) 					// 90+ at diagnosis
replace targetpop = 0 if ( inlist(SNbasis, 81, 90) ) 	///
				  | (SNbasis == 23 & SXstraale == 0) 	// DCO, autopsy
replace targetpop = 0 if ( !inlist(figo,3,4 ) )  		// FIGO I,II,Unknown

lab variable targetpop "Target population, main analysis"


** Main study population, 2013-2022

gen spop = targetpop 
replace spop = 0 if ( has_k100 == 0 )	// No clinical diagnostic report
replace spop = 0 if ( has_k200 == 0 ) 	// Operated but no surgical report 

lab variable spop "Study population, main analysis"


** Secondary study population (SACT), 2019-2022

gen ispop = spop 
replace ispop = 0 if ( year < 2019 )	// No SACT data before 2019
replace ispop = 0 if ( region == 1800 )	// No SACT data in Northern Norway

lab variable ispop "Secondary analysis"


********************************************************************************
** Stset 
********************************************************************************

capture drop id 
gen id = _n 

stset P_statusdato, id(id)						///
					fail(dead == 1) 			///
					origin(surgerydate) 		///
					enter(surgerydate) 			///
					exit(time td(31oct2023))	///
					scale(365.24) 


********************************************************************************
** Merge expected mortality
** Life tables stratified by residential health trust (hf), year, age and sex
********************************************************************************

gen _age = int( ( surgerydate + ( _t * 365.24 ) - dateofbirth ) / 365.24 )
replace _age = 99 if _age > 99 

gen _year = year( surgerydate + ( _t * 365.24 ) )
sort _year _age

merge m:1 hf _year _age sex using "life_table_hf.dta", keep(match master) nogen keepusing(prob) 
drop _age _year

gen fitmx = -log(prob)


********************************************************************************

save "ovca2.dta", replace

exit