
********************************************************************************
** Table 3: Excess Hazard ratios by surgical and residual disease (RD) status
** in the context of systemic anti-cancer therapy
********************************************************************************

use "ovca2.dta", clear 

keep if ispop == 1		// Study population with SACT data (2019-2022)
keep if opr == 1 		// Operated

drop if inlist(ct,0,1)			// No adjuvant chemotherapy
drop if ( rd == 99 ) 			// Unknown residual disease status 
drop if ( rd == 2 ) & mi(rdcm)	// Residual disease but unknown diameter


********************************************************************************

** Surgery category 

gen ct_neo = ( ct == 2 ) 
lab def ct_neo_lab 			///
	0 "Primary surgery"		///
	1 "Neoadjuvant chemotherapy and interval surgery"
lab val ct_neo ct_neo_lab 


** Residual disease category 

egen rdcm_gp = cut(rdcm), at(0.1 1.0 1.1) label	
replace rdcm_gp = rdcm_gp + 1
replace rdcm_gp = 0 if ( rd == 1 )

lab def rdcm_gp_lab 			///
	0 "No residual disease"		///
	1 "0.1-0.9 cm"				///
	2 "1.0 cm"					///
	3 "1.1-20 cm", modify
lab val rdcm_gp rdcm_gp_lab 
	

** Combine ECOG 2-4 into single group
recode ecog (2/4 = 2)
lab def ecog_lab 				///
	0 "O: Fully active" 		///
	1 "1: Restricted activity" 	///
	2 "2-4", modify 


** combine endometroid, adenocarcinoma (low/unknown grade) and other epithelial
recode histotype ( 6/8 = 6 )
lab def histotype_lab 6 "Other", modify 


********************************************************************************
** Expand data so have one model for all histotypes and one model for HGS

gen hist2 = 1 
expand 2 if ( histotype == 1 ), gen(expanded)
replace hist2 = 2 if expanded 
 
lab def hist2_lab 		///
	1 "All histotypes" 	///
	2 "High-grade serous"
lab val hist2 hist2_lab 


********************************************************************************
** Model 1: All histotypes 
********************************************************************************

stpm2 i.ct_neo#i.rdcm_gp i.ct_neo i.ct_maintenanceAdj 					///
		i.figo i.ecog age i.histotype if ( hist2 == 1 ), 				///
		scale(hazard) df(5) bhazard(fitmx) eform 						///
		tvc(h1) dftvc(2)


** Wald test P-value 
testparm i.ct_neo
testparm i.ct_maintenanceAdj
testparm i.figo
testparm i.ecog
testparm age
testparm i.histotype


********************************************************************************
** Model 2: High-grade serous
********************************************************************************

stpm2 i.ct_neo#i.rdcm_gp i.ct_neo i.ct_maintenanceAdj 					///
		i.figo i.ecog age if ( hist2 == 2 ), 							///
		scale(hazard) df(5) bhazard(fitmx) eform 						///
		tvc(h1) dftvc(2)

		
** Wald test P-value 
testparm i.ct_neo
testparm i.ct_maintenanceAdj
testparm i.figo
testparm i.ecog
testparm age
