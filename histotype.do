
capture drop histotype 

gen histotype = . 

lab def histotype_lab							///
	1 "High-grade Serous"						///
	2 "Low-grade Serous"						///
	3 "Carcinosarcoma" 							///
	4 "Mucinous"								///
	5 "Clear Cell"								///
	6 "Endometroid"								///
	7 "Adenocarcinoma (low/unknown grade)"		///
	8 "Other epithelial (including Brenner)"	
	
lab val histotype histotype_lab 
lab variable histotype "Invasive epithelial histotype"


********************************************************************************
** High-grade serous 

replace histotype = 1 if 											 /// 
	  ( inlist(S_morfologiIcdo3, 846039, 846139 ) & ( year < 2016) ) ///
	  | 															 ///
	  ( inlist(S_morfologiIcdo3, 846139 ) & ( year >= 2016) ) 	 	 ///
	  | 															 ///
		inlist(S_morfologiIcdo3, 									 ///
					805033, 										 ///
					826032, 										 ///
					826033, 										 ///
					826034, 										 ///
					844132, 										 ///
					844133, 										 ///
					844134, 										 ///
					845032, 										 ///
					845033, 										 ///
					845034, 										 ///
					846032, 										 ///
					846033, 										 ///
					846034, 										 ///
					846132, 										 ///
					846133, 										 ///
					846134, 										 ///
					838033, 										 ///
					838034, 										 ///
					838133, 										 ///
					838134, 										 ///
					856033, 										 ///
					856034, 										 ///
					857033, 										 ///
					857034, 										 ///	
					802034, 										 /// 
					814032, 										 /// 
					814033, 										 ///
					814034, 										 ///
					825532, 										 ///
					825533, 										 ///
					825534, 										 /// 
					851033, 										 ///					
					805039, 										 ///
					826039,										     ///
					844139,											 ///
					845039 )
	
	
********************************************************************************
** Low-grade serous 

replace histotype = 2 if 											 /// 
		( inlist(S_morfologiIcdo3, 846039 ) & ( year >= 2016) ) 	 ///
		| inlist(S_morfologiIcdo3, 									 ///
					805031, 										 ///
					826031, 										 ///
					844131, 										 ///
					845031, 										 ///
					846031, 										 ///
					846131 )

					
********************************************************************************
** Carcinosarcoma

replace histotype = 3 if  										     /// 	
		inlist(SXmorfologiIcdo3_5, 									 ///
					89403, 											 ///
					89503, 											 ///
					89513, 											 ///
					89803 )

					
********************************************************************************
** Mucinous

replace histotype = 4 if  											 /// 
		inlist(SXmorfologiIcdo3_5, 									 ///
					84703, 											 ///
					84713, 											 ///
					84723, 											 ///
					84743, 											 ///
					84803, 											 ///
					84813, 											 ///
					84823 )

					
********************************************************************************
** Clear Cell 

replace histotype = 5 if 											 /// 
		inlist(SXmorfologiIcdo3_5, 									 ///
					83103, 											 ///
					83133 )  
	
********************************************************************************
** Endometroid

replace histotype = 6 if 											 /// 
		inlist(S_morfologiIcdo3, 									 ///
					838031, 										 ///
					838032, 										 ///
					838131, 										 ///
					838132, 										 ///
					856031, 										 ///
					856032, 										 ///
					857031, 										 ///
					857032, 										 ///
					838039, 										 ///
					838139, 										 ///
					856039, 										 ///
					857039 )

					
********************************************************************************
** Adenocarcinoma (low or unknown grade)

replace histotype = 7 if 											 /// 
	  inlist(S_morfologiIcdo3, 										 ///
					814031, 										 ///
					814039, 										 ///
					825531, 										 ///
					825539, 										 ///
					851039 ) 

					
********************************************************************************
** Other epithelial / Brenner 

replace histotype = 8 if 											 /// 
	  inlist(S_morfologiIcdo3, 										 ///
					802039, 										 ///
					802139, 										 ///
					911139) 										 ///
	  | inlist(SXmorfologiIcdo3_5, 									 ///
					80103, 										 	 ///
					82303, 										 	 ///
					84403,											 ///
					90003)	 										 ///  
	  | inlist(SXmorfologiIcdo3_4), 								 ///
					8013, 											 ///
					8030, 											 ///
					8032, 											 ///
					8033, 											 ///
					8041, 											 ///
					8046, 											 ///
					8244, 											 ///
					8323, 											 ///
					8473, 											 ///
					8490, 											 ///
					8562, 											 ///
					8576,  											 ///
					8120,	   										 ///
					8130 )
