
********************************************************************************
** Table 1: Surgical and residual disease status by patient characteristics
********************************************************************************

use "ovca2.dta", clear 

keep if spop == 1					// Main study population

********************************************************************************
/*
** Recoding for tabulation 

recode ct_regimenNeo ( 0 = . )
recode ct_regimenNeo ( 1 = 2 ) if ( ct_bevacNeo == 1 )
lab def reg_lab ///
	1 "Platinum-based + Taxane" ///
	2 "Platinum-based + Taxane + Bevacizumab"
lab val ct_regimenNeo reg_lab 

recode ct_cyclesNeo ( 0 = . ) ( 3 = 2 ) // only 1 with 7, put with 4-6
*/


********************************************************************************
** Variables 
********************************************************************************

local varlist "topography histotype figo agegroup period region ecog comorbidity ct ct_regimenNeo ct_cyclesNeo"


********************************************************************************
** Cytoreductive surgery, %
********************************************************************************

gen ant == 1 

foreach covar of varlist `varlist'  {

	preserve 

		collapse (sum) tot = ant (mean) opr if !mi(`covar'), by(`covar')
		gen opr_pct = string(round(opr * 100, 0.1 )) + "%"

		tempfile N`covar' 
		save `N`covar'', replace 

	restore 

	}


********************************************************************************
** Residual disease status, N (%), chi-squared P-value
********************************************************************************

keep if ( opr == 1 )			// Operated patients


** N (%)
foreach covar of varlist `varlist' {

	preserve 

		collapse (sum) ant, by(`covar' rd)
		bysort `covar' (rd): gen rd_pct = string(ant/ant[1] * 100, "%03.1f" )	

		tempfile RD`covar' 
		save `RD`covar'', replace 

	restore 

}


** Chi-squared
foreach covar of varlist `varlist' {
				
	tab `covar' rd if ( `covar' != 99 ), chi row
	global chi_`covar' = string(r(p), "%04.3f" )
			
} 

********************************************************************************
** Diameter of residual disease in abdominal cavity, cm 
********************************************************************************

foreach covar of varlist `varlist'  {

	preserve 
	
		collapse (median) median = rdcm 						///
				 (mean) mean = rdcm 							///
				 (sd) sd = rdcm 								///
				 (max) max = rdcm 								///
				 if !mi(`covar'), by(`covar')
		
		replace median = round(median, 0.1)
		replace mean = round(mean, 0.1)
		replace sd = round(sd, 0.1)
		replace max = round(max, 0.1)

		gen max_str = string(max)
		replace max_str = ">15" if inrange(max, 15, 20)
	
		tempfile RDCM`covar' 
		save `RDCM`covar'', replace 
	
	restore 
	
}
