* * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * *
* * 	MAIN THESIS DO		* *
* * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * *

* PREPARE DATASETS: ONE FOR SCS&W8, ONE FOR W8 ONLY.

********************************************************************************
********************************************************************************
*					1 : OxGRT variables and file	  	
********************************************************************************
********************************************************************************
* File that contains all monthly averages and 30 day averages up to a specific month 

*	*	*	*	*	*	*
* STEP 1.1: INDEXES FILE	*
*	*	*	*	*	*	*
/*
cd "C:\Users\Jessica\Desktop\Data for thesis"
use "OxGRT.dta", clear

* Extract year, month, day
rename date long_date
tostring long_date, gen(date)
gen year = substr(date, 1, 4)
gen month = substr(date, 5, 2)
gen day = substr(date, 7, 2)
destring year month day, replace

keep if year == 2020

keep location regionname jurisdiction date stringencyindex_average governmentresponseindex_average containmenthealthindex_average economicsupportindex year month day
sort location month 

* Generate average monthly values for indexes:
	by location month: egen avgSCS_SI	= mean(stringencyindex_average)
	by location month: egen avgSCS_GRI	= mean(governmentresponseindex_average)
	by location month: egen avgSCS_CHI	= mean(containmenthealthindex_average)
	by location month: egen avgSCS_ESI	= mean(economicsupportindex)
	
	collapse (mean) avgSCS_SI avgSCS_GRI avgSCS_CHI avgSCS_ESI, by(location year month)

* Generate averages up to a specific month: 
	bysort location: gen upto_month_avgSCS_SI 	= sum(avgSCS_SI) / _n
	bysort location: gen upto_month_avgSCS_GRI 	= sum(avgSCS_GRI) / _n
	bysort location: gen upto_month_avgSCS_CHI 	= sum(avgSCS_CHI) / _n
	bysort location: gen upto_month_avgSCS_ESI 	= sum(avgSCS_ESI) / _n
	
rename location country
save "OxGRT_indexes.dta", replace
*/

*	*	*	*	*	*	*	*
* STEP 1.2: STATISTICS FILE	*
*	*	*	*	*	*	*	*
/*
use "OxGRTreduced.dta", clear

* Extract year, month, day
gen year = substr(date, 1, 4)
gen month = substr(date, 6, 2)
gen day = substr(date, 9, 2)
destring year month day, replace
tab year
keep if year == 2020

keep location 	date 	year 	month 	day 	total_cases_per_million	 new_cases_per_million	 total_deaths_per_million	 new_deaths_per_million	 icu_patients_per_million	 hosp_patients_per_million	total_tests_per_thousand	 new_tests_per_thousand	 positive_rate	 hospital_beds_per_thousand

sort location month

* Generate average monthly values for indexes:
	by location month: egen avg_tot_cases_per_m		= mean(total_cases_per_million)
	by location month: egen avg_new_cases_per_m		= mean(new_cases_per_million)
	by location month: egen avg_tot_deaths_per_m	= mean(total_deaths_per_million)
	by location month: egen avg_new_deaths_per_m	= mean (new_deaths_per_million)
	by location month: egen avg_icu_patients_per_m	= mean(icu_patients_per_million)
	by location month: egen avg_hosp_patients_per_m	= mean(hosp_patients_per_million)
	by location month: egen avg_tot_test_per_k		= mean(total_tests_per_thousand)
	by location month: egen avg_new_test_per_k		= mean(new_tests_per_thousand)
	by location month: egen avg_positivity_rate		= mean(positive_rate)
	by location month: egen avg_hosp_beds_per_k		= mean(hospital_beds_per_thousand)

	collapse (mean) avg_tot_cases_per_m avg_new_cases_per_m avg_tot_deaths_per_m avg_new_deaths_per_m avg_icu_patients_per_m avg_hosp_patients_per_m avg_tot_test_per_k avg_new_test_per_k avg_positivity_rate avg_hosp_beds_per_k, by(location year month)

* Generate averages up to a specific month: 
	bysort location: gen upto_month_avg_totcasesperm 	= sum(avg_tot_cases_per_m) / _n
	bysort location: gen upto_month_avg_newcasesperm 	= sum(avg_new_cases_per_m) / _n
	bysort location: gen upto_month_avg_totdeathsperm 	= sum(avg_tot_deaths_per_m) / _n
	bysort location: gen upto_month_avg_newdeathsperm 	= sum(avg_new_deaths_per_m) / _n
	bysort location: gen upto_month_avg_icupatientsperm = sum(avg_icu_patients_per_m) / _n
	bysort location: gen upto_month_avg_hosppatientsperm	= sum(avg_hosp_patients_per_m) / _n
	bysort location: gen upto_month_avg_tottestperk 	= sum(avg_tot_test_per_k) / _n
	bysort location: gen upto_month_avg_newtestperk 	= sum(avg_new_test_per_k) / _n
	bysort location: gen upto_month_avgpositivityrate 	= sum(avg_positivity_rate) / _n
	bysort location: gen upto_month_avghospbedsperk 	= sum(avg_hosp_beds_per_k) / _n

rename location country
save "OxGRT_statistics.dta", replace
*/

*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
* STEP 1.3: MERGE INDEXES AND STATISTICS INTO A SINGLE FILE	*
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
/*
use "OxGRT_statistics.dta", clear
merge 1:1 country month using "C:\Users\Jessica\Desktop\Data for thesis\OxGRT_indexes.dta"
keep if _merge == 3 /* drops Slovakia and Czech Republic */
drop _merge 
gen merge_month = month
save "C:\Users\Jessica\Desktop\Thesis_MEF\OxGRT_indexes_statistics.dta", replace
*/

* Renaming vars & adding labels
use "OxGRT_indexes_statistics.dta", clear
rename upto_month_avgSCS_SI upto_month_avg_SI
rename upto_month_avgSCS_GRI upto_month_avg_GRI
rename upto_month_avgSCS_CHI upto_month_avg_CHI
rename upto_month_avgSCS_ESI upto_month_avg_ESI
label variable upto_month_avg_newcasesperm "Average monthly new cases up to month of interview (SCS or W8 depending on merge), per million"
save "OxGRT_indexes_statistics.dta", replace




********************************************************************************
********************************************************************************
*						2: W8 MODELS DATASET CREATION
********************************************************************************
********************************************************************************
* File to be used for models that require only w8 data 
* Note: all OxGRT data is associated to individuals using int_month_do or int_month variables which mark the beginning OR end month of the w8 interview process


*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 2.1: GENERATE W8 SLIMMER DATASET	*
*	*	*	*	*	*	*	*	*	*	*	*
/* big drop 
use "w8babymerge.dta", clear
/* Drop useless vars:
drop at_f1 at_f2 at_f3_1 at_f3_2 at_f3_3 at_f3_4 at_f3_5 at_f3_6 at_f3_7 at_f3_8 at_f3_9 at_f4_1 at_f4_2 at_f4_3 at_f4_4 at_f4_5 at_f4_6 at_f4_7 at_f4_8 at_f4_9 at_f5 at_f6 at_f7_1 at_f7_2 at_f7_3 at_f7_4 at_f7_5 at_f7_6 at_f7_7 at_f7_8 at_f7_9 at_f7_10 at_f7_11 at_f8_1 at_f8_2 at_f8_3 at_f8_4 at_f8_5 at_f8_6 at_f9a at_f9b at_f9c at_f9d at_f9e at_f9f at_f9g at_f10a at_f10b at_f10c at_f10d at_f10e at_f10f at_f10g at_f10h at_f10i at_f10j at_f10k at_f11a at_f11b at_f11c at_f11d at_f11e at_f11f at_f11g at_f11h be_fr_q1 be_fr_q2 be_fr_q3 be_fr_q4 be_fr_q5 be_fr_q5a_months be_fr_q5b_years be_fr_q6 be_fr_q7 be_fr_q8a be_fr_q8b be_fr_q8c be_fr_q8d be_fr_q8e be_fr_q8f be_fr_q9 be_fr_q10 be_fr_q11 be_fr_q12_day be_fr_q12_month be_fr_q12_year be_fr_q13a be_fr_q13b be_fr_q13c be_fr_q13d be_fr_q13e be_fr_q13f be_fr_q13g be_fr_q14a be_fr_q14b be_fr_q14c be_nl_q1 be_nl_q2 be_nl_q3 be_nl_q4 be_nl_q5 be_nl_q5a_months be_nl_q5b_years be_nl_q6 be_nl_q7 be_nl_q8a be_nl_q8b be_nl_q8c be_nl_q8d be_nl_q8e be_nl_q8f be_nl_q9 be_nl_q10 be_nl_q11 be_nl_q12_day be_nl_q12_month be_nl_q12_year be_nl_q13a be_nl_q13b be_nl_q13c be_nl_q13d be_nl_q13e be_nl_q13f be_nl_q13g be_nl_q14a be_nl_q14b be_nl_q14c ch_q1_a ch_q1_b ch_q1_c ch_q1_d ch_q1_e ch_q1_f ch_q1_g ch_q1_h ch_q1_i ch_q1_j ch_q1_k ch_q1_l ch_q1_m ch_q1_n ch_q1_o ch_q1_p ch_q1_q ch_q1_r ch_q1_s ch_q2_a ch_q2_b ch_q2_c ch_q2_d ch_q2_e ch_q2_f ch_q3_a ch_q3_b ch_q3_c ch_q3_d ch_q3_e ch_q4_a ch_q4_b ch_q4_c ch_q4_d ch_q4_e ch_q4_f ch_q4_g ch_q5_a ch_q5_b ch_q5_c ch_q5_d ch_q5_e ch_q5_f ch_q5_g ch_q5_h ch_q5_i ch_q5_j ch_q5_k ch_q5_l ch_q5_m ch_q5_n ch_q6_a ch_q6_b ch_q6_c ch_q7 ch_q8 ch_q9 ch_q10_a ch_q10_b ch_q10_c ch_q10_d ch_q10_e ch_q10_f ch_q11 ch_q12_a ch_q12_b ch_q12_c ch_q12_d ch_q12_e ch_q12_f ch_q13 ch_q14_a ch_q14_b ch_q14_c ch_q14_d ch_q14_e ch_q14_f ch_q14_g ch_q14_h ch_q15 ch_q16 ch_q17_a ch_q17_b ch_q17_c ch_q17_d ch_q17_e ch_q17_f ch_q18 ch_q19 ch_q20 ch_q21 ch_q22 ch_q23 ch_q24_a ch_q24_b ch_q25_a ch_q25_b ch_q26_a ch_q26_b ch_q26_c ch_q26_d ch_q26_e ch_q26_f ch_q26_g ch_q26_h ch_q26_i ch_q26_j ch_q26_k ch_q27 ch_q28 ch_q29 ch_q30_a ch_q30_b ch_q30_c ch_q30_d ch_q30_e ch_q30_f ch_q30_g ch_q30_h ch_q30_i ch_q30_j ch_q30_k ch_q30_l ch_q33 cz_A1 cz_A2a cz_A2b cz_A2c cz_A2d cz_A3a cz_A3b cz_A3c cz_B1 cz_B2 cz_B3 cz_B4 cz_B5 cz_C1a cz_C1b cz_C1c cz_C1d cz_C1e cz_C1f cz_C2a cz_C2b cz_C2c cz_C2d cz_C2e cz_C2f cz_D1 cz_D2 cz_D3 cz_D4 cz_D5 cz_D6 cz_D7 cz_D8a cz_D8b cz_D8c cz_D8d cz_D8e cz_D8f cz_D9 cz_D10 cz_D11 cz_E1 cz_E2 cz_E3 cz_E4 cz_E5 cz_F1a cz_F1b cz_F1c cz_F1d cz_F1e cz_F1f cz_F1g cz_F1h cz_F2a cz_F2b cz_F2c cz_F2d cz_F2e cz_F2f cz_F2g cz_F2h cz_F3a cz_F3b cz_F3c cz_F3d cz_F3e cz_F3f cz_F4a cz_F4b cz_F4c cz_F4d cz_F4e cz_F4f cz_F5a cz_F5b cz_F5c cz_F5d cz_F5e cz_F5f cz_F5g cz_F5h cz_G1 cz_G2a cz_G2b cz_G3a cz_G3b cz_G3c cz_G3d cz_G3e cz_G3f cz_G4a cz_G4b cz_G4c cz_G4d cz_G4e cz_G4f cz_G4g cz_H1 cz_I1 cz_I2 cz_I3 cz_J1a cz_J1b cz_J2 cz_J3 cz_J4 cz_J5a cz_J5b cz_J5c cz_Ka cz_Kb cz_Kc cz_Kd cz_Ke cz_Kf cz_Kg cz_Kh cz_Ki cz_Kj cz_Kk cz_Kl cz_Km cz_Kn cz_Ko cz_Kp cz_M0 cz_M1 cz_M2 cz_M3a cz_M3b cz_M3c cz_M3d cz_M3e cz_M3f cz_M3g cz_M3ap cz_M3bp cz_M4 cz_M5a cz_M5b cz_M5c cz_M5d cz_M6 dk_S1 dk_S2 dk_S3 dk_S4 dk_S5 dk_S6 dk_S7 dk_S8 dk_S9_1 dk_S9_2 dk_S9_3 dk_S10_1 dk_S10_2 dk_S10_3 dk_S11 ee_k12 ee_K16 ee_K17 ee_K18 ee_K19 ee_K20 ee_K21 ee_K22 ee_K231 ee_K232 ee_K233 ee_K234 ee_K235 ee_K236 ee_K24 ee_K25 ee_K26 ee_K261 ee_K28 ee_K281 ee_K29 ee_K30 ee_K301 ee_K302 ee_K31 ee_K311 eg_P1 eg_P2 eg_P3 eg_P4 eg_P5a eg_P5b eg_P5c eg_P5d eg_P5e eg_P5f eg_p5g eg_P5h eg_P5i eg_P5j eg_P6 eg_P7 eg_P8 eg_P9 eg_P10 eg_P11a eg_P11b eg_P11c eg_P11d eg_P11e eg_P12 eg_P13 eg_P14 eg_P15 eg_P16 eg_G1 eg_G2 eg_G3 eg_G4 eg_G5 eg_G6 eg_G7 eg_G8 eg_G9 eg_G10 eg_G11 eg_G12 eg_G13 es_q1 es_q2 es_q3 es_q4 es_q5 es_q5a_months es_q5b_years es_q6 es_q7 es_q8a es_q8b es_q8c es_q8d es_q8e es_q8f es_q9 es_q10 es_q11 fi_h01_1 fi_h01_2 fi_h01_3 fi_h01_4 fi_h02 fi_h03 fi_h04 fi_h05 fi_h06 fi_h07 fi_h08 fi_h09 fi_h10 fi_h12_1 fi_h12_2 fi_h12_3 fi_h12_4 fi_h12_5 fi_h12_6 fi_h12_7 fi_h12_8 fi_h12_9 fi_h12_10 fi_h13_1 fi_h13_2 fi_h13_3 fi_h13_4 fi_h13_5 fi_h13_6 fi_h13_7 fi_h13_8 fi_h13_9 fi_h13_10 fi_h13_11 fi_h13_12 fi_h13_13 fi_h13_14 fi_h13_15 fr_do01_ald fr_do02_sup fr_do03_cmu fr_do04_emp fr_do05_acs fr_do06_spe fr_do06_dru fr_do06_hos fr_do06_den fr_do06_hea fr_do07_pay fr_do07_per fr_do08_peo fr_do09_aff fr_do09_ald fr_do09_nee fr_do09_ret fr_do09_tim fr_do09_how fr_do09_sub fr_do09_oth fr_do09_dkw fr_do10_job fr_do10_ret fr_do10_sit fr_do10_los fr_do10_oth fr_do10_no fr_do10_dkw fr_do11_sup fr_do11_ltc fr_do11_loa fr_do11_oth fr_do11_no fr_do11_dkw fr_do12_ris fr_do13_fut fr_do14_imp fr_do15_urn fr_do16_don fr_do17_don fr_do18_mon fr_do19_5y fr_do19_10y fr_do19_20y fr_do20_5y fr_do20_10y fr_do20_20y il_Q1 il_Q2_1 il_Q2_2 il_Q2_3 il_Q2_4 il_Q2_5 il_Q2_6 il_Q2_7 il_Q2_8 il_Q2_9 il_Q2_10 il_Q3_1 il_Q3_2 il_Q3_3 il_Q3_4 il_Q3_5 il_Q3_6 il_Q3_7 il_Q3_8 il_Q4_1 il_Q4_2 il_Q4_3 il_Q5_1 il_Q5_2 il_Q5_3 il_Q5_4 il_Q5_5 il_Q5_6 il_Q6_1 il_Q6_2 il_Q6_3 il_Q6_4 il_Q6_5 il_Q6_6 il_Q6_7 il_Q7_1 il_Q7_2 il_Q7_3 il_Q7a_4 il_Q7b_5 il_Q7c_6 it_q1 it_q2 it_q3 it_q4 it_q5 it_q5a_months it_q5b_years it_q6 it_q7 it_q8a it_q8b it_q8c it_q8d it_q8e it_q8f it_q9 it_q10 it_q11 lu_CAT lu_Q1_a1 lu_Q1_a2 lu_Q1_b1 lu_Q1_b2 lu_Q2_ lu_Q3_ lu_Q4_1 lu_Q4_2 lu_Q4_3 lu_Q4_4 lu_Q5_ lu_Q6_ lu_Q7_ lu_Q8_1 lu_Q8_2 lu_Q8_3 lu_Q9_ pl_Q1d1 pl_Q1d2 pl_Q1d3 pl_Q1d4 pl_Q1d5 pl_Q1d6 pl_Q1d7 pl_Q1d8 pl_Q2d1 pl_Q2d2 pl_Q2d3 pl_Q2d4 pl_Q2d5 pl_Q2d6 pl_Q2d7 pl_Q2d8 pl_Q3d1 pl_Q3d2 pl_Q3d3 pl_Q3d4 pl_Q3d5 pl_Q4d1 pl_Q4d2 pl_Q4d3 pl_Q4d4 pl_Q5d1 pl_Q5d2 pl_Q6d1 pl_Q6d2 pl_Q6d3 pl_Q6d4 pl_Q6d5 pl_Q6d6 pl_Q6d7 pl_Q6d8 pl_Q6d9 pl_Q6d10 pl_Q6dno pl_Q7 pl_Q8d1 pl_Q8d2 pl_Q8d3 pl_Q8d4 pl_Q8d5 pl_Q8d6 pl_Q8d7 pl_Q8d8 pl_Q9d1 pl_Q9d2 pl_Q9d3 pl_Q9d4 pl_Q10d1 pl_Q10d2 pl_Q10d3 pl_Q10d4 pl_Q10d5 pl_Q10d6 pl_Q11 pl_Q12 pl_Q13 pl_Q14d1 pl_Q14d2 pl_Q14d3 pl_Q14d4 pl_Q14d5 pl_Q14d6 pl_Q14d7 pl_Q15a pl_Q15b pl_Q16 pl_Q17 pl_sample ro_A1 ro_A2 ro_A3 ro_A4 ro_A5 ro_B1 ro_B2 ro_B3 ro_B4 ro_B5 ro_B6 ro_B7 ro_B8 ro_B9 ro_B10 ro_B11 ro_D1 ro_D2 ro_D3 ro_D4 ro_D5 ro_D6 ro_D7 ro_D8 ro_D9 ro_E1 ro_E2 ro_E3 ro_E4 ro_F ro_G1 ro_G2 si_q1need_1 si_q1rcv_1 si_q1need_2 si_q1rcv_2 si_q1need_3 si_q1rcv_3 si_q1need_4 si_q1rcv_4 si_q1need_5 si_q1rcv_5 si_q1need_6 si_q1rcv_6 si_q1need_7 si_q1rcv_7 si_q1need_8 si_q1rcv_8 si_q1need_9 si_q1rcv_9 si_q1need_10 si_q1rcv_10 si_q1need_11 si_q1rcv_11 si_q1need_12 si_q1rcv_12 si_q1need_13 si_q1rcv_13 si_q1need_14 si_q1rcv_14 si_q1need_15 si_q1rcv_15 si_q2 si_q3 si_q4a si_q4b si_q4c si_q4d si_q4e si_q4f si_q4g si_q4h si_q4i si_q4j si_q5a si_q5b si_q5c si_q5d si_q5e si_q5f si_q5g si_q5h si_q5i si_q6 si_q7a si_q7b si_q8 si_q9
*/

save "W8_slimmer.dta", replace
*/


*	*	*	*	*	*	*	*	*	*
*	STEP 2.2: ATTACH OXGRT DATA 	*
*	*	*	*	*	*	*	*	*	*
/* merge with OxGRT according to W8 int_month --> when using this file for models, the instruments go up to w8 int_month
use "W8_slimmer.dta", clear

keep if int_year == 2020 /* 45,026 individuals have mergeid but did not do interview at all, 22,997 are done in 2019 */
gen merge_month = int_month 
tab merge_month
merge m:1 country merge_month using "OxGRT_indexes_statistics.dta"
keep if _merge == 3 /* 1,755 are Slovakia and Czech Republic, 107 are empty lines */
drop _merge 

save "W8_OxGRT_models.dta", replace
*/

* 53,870 sample --> discrepancy with SCS+W8 depends on merge_month variable being more available in SCS


********************************************************************************
********************************************************************************
*						3: W8+SCS MODELS DATASET CREATION
********************************************************************************
********************************************************************************
* File to be used for models in which dependent vars come from SCS 
* Dataset contains only individuals that are in BOTH w8 and SCS
* Note: all OxGRT data is associated to individuals using int_month_ca variable that marks when the SCS was done for an individual


*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 3.1: GENERATE A FULL SCS DATASET	*
*	*	*	*	*	*	*	*	*	*	*	*
/*
cd "C:\Users\Jessica\Desktop\SHAREDATA\sharew8ca_rel8-0-0_ALL_datasets_stata"
use "sharew8ca_rel8-0-0_ca.dta", clear
tab country

* Append Austria (in a separate module because collection was in different months: July-Sept instead of June-August)
append using "C:\Users\Jessica\Desktop\SHAREDATA\sharew8ca_rel8-0-0_ALL_datasets_stata\sharew8ca_rel8-0-0_ca_austria.dta", nolabel
tab country

* Merge with coverscreen information
merge 1:1 mergeid using "C:\Users\Jessica\Desktop\SHAREDATA\sharew8ca_rel8-0-0_ALL_datasets_stata\sharew8ca_rel8-0-0_cv_r.dta", nolabel
* _merge == 2 /* individuals only in the SCS and not W8 */
tab interview_ca
keep if interview_ca == 1
rename _merge coverscreen_merge

* Note: SCS dataset is not only made of individuals that are in both w8 and SCS
save "C:\Users\Jessica\Desktop\Thesis_MEF\SCS_only_dataset.dta", replace
*/

*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 3.2: ATTACH OxGRT VARIABLES 		*
*	*	*	*	*	*	*	*	*	*	*	*
/* INSTRUMENTS IN THIS FILE GO UP TO int_month_ca

use "SCS_only_dataset.dta", clear

rename country country_old
decode country_old, generate(country)
drop if country == "Slovakia" | country == "Czech Republic"
gen merge_month = int_month_ca
tab int_month_ca
merge m:1 country merge_month using "OxGRT_indexes_statistics.dta"
keep if _merge == 3 /* 237 units do not have data in any scs var, not even mergeid */
drop _merge

save "SCS_OxGRT.dta", replace
*/

*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 3.3: MERGE W8 DATA WITH SCS DATA 	*
*	*	*	*	*	*	*	*	*	*	*	*
/*
/* W8BABYMERGE FILE: fixing str byte incompatbility pre merge [DONE AND SAVED: DO NOT RERUN]
use "w8babymerge.dta", clear
rename country country_old
decode country_old, generate(country)
tab country
save "w8babymerge.dta", replace
*/

use "SCS_OxGRT.dta", clear
merge 1:1 mergeid using "w8babymerge.dta"
* _merge == 2  count: 38,376 people in w8 but not in SCS, 3,689 in Slovakia and Czech Republic, FOR A TOTAL OF 42,065 
keep if interview_ca == 1
keep if _merge == 3

save "SCS_W8_OxGRT_models.dta", replace
*/


* 26,157 sample --> smaller sample because merge_month variable is not that available



********************************************************************************
********************************************************************************
*					4 : VARIABLE GENERATION & MH INDEXES	  	
********************************************************************************
********************************************************************************
cd "C:\Users\Jessica\Desktop\FINAL DATASETS TO USE"
use "SCS_W8_OxGRT_models.dta", clear 

*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 4.1: GENERATE A MENTAL HEALTH INDEX USING camh VARS	*
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
/* FINAL mh_ca INDEX TAKES VALUES BETWEEN 0 - 7. [ SAVED IN FILE ]
* Add 1 for every negative mh manifestation from the mh questions
gen depr1m = .
	replace depr1m = 0 if camh002_ == -1 | camh002_ == 5
	replace depr1m = 1 if camh002_ == 1

gen more_depr = .
	replace more_depr = 0 if camh802_ == -9 | camh802_ == -1 | camh802_ == 3
	replace more_depr = -0.5 if camh802_ == 2
	replace more_depr = 1 if camh802_ == 1

gen sleepless1m = .
	replace sleepless1m = 0 if camh007_ == -1 | camh007_ == 2
	replace sleepless1m = 1 if camh007_ == 1

gen more_sleepless = .
	replace more_sleepless = 0 if camh807_ == -9 | camh807_ == -1 | camh807_ == 3
	replace more_sleepless = -0.5 if camh807_ == 2
	replace more_sleepless = 1 if camh807_ == 1

gen lonely = .
	replace lonely = 0 if camh037_ == -1 | camh037_  == 3
	replace lonely = 1 if camh037_ == 2
	replace lonely = 2 if camh037_  == 1

gen more_lonely = .
	replace more_lonely = 0 if camh837_ == -9 | camh837_ == -1 | camh837_ == 3
	replace more_lonely = -0.5 if camh837_ == 2
	replace more_lonely = 1 if camh837_ == 1

tab camh002_ depr1m
tab camh802_ more_depr
tab camh007_ sleepless1m
tab camh807_ more_sleepless
tab camh037_ lonely
tab camh837_ more_lonely

egen mh_ca = rowtotal(depr1m more_depr sleepless1m more_sleepless lonely more_lonely)
tab mh_ca 

save "SCS_W8_OxGRT_models.dta", replace
*/


*	*	*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 4.2: GENERATE ALL SCS RELEVANT VARIABLES	*
*	*	*	*	*	*	*	*	*	*	*	*	*	*

*use "SCS_W8_OxGRT_models.dta", clear

use "SCS_W8_OxGRT_models_WITH_VARS.dta", clear

*feel out of control 
gen outofcontrol = .
replace outofcontrol = 0 if ac015_ == 4
replace outofcontrol = 0.5 if ac015_ == 3
replace outofcontrol = 1 if ac015_ == 2
replace outofcontrol = 2 if ac015_ == 1
tab ac015_ outofcontrol
* feel left out of things
gen leftout = .
replace leftout = 0 if ac016_ == 4
replace leftout = 0.5 if ac016_ == 3
replace leftout = 1 if ac016_ == 2
replace leftout = 2 if ac016_ == 1
tab ac016_ leftout
* look forward to each day 
gen lookforw = .
replace lookforw = 2 if ac020_ == 4
replace lookforw = 1 if ac020_ == 3
replace lookforw = 0.5 if ac020_ == 2
replace lookforw = 0 if ac020_ == 1
tab ac020_ lookforw
* life has meaning 
gen lifemeaning = .
replace lifemeaning = 2 if ac021_ == 4
replace lifemeaning = 1 if ac021_ == 3
replace lifemeaning = 0.5 if ac021_ == 2
replace lifemeaning = 0 if ac021_ == 1
tab ac021_ lifemeaning
* feel full of energy 
gen energetic = .
replace energetic = 2 if ac023_ == 4
replace energetic = 1 if ac023_ == 3
replace energetic = 0.5 if ac023_ == 2
replace energetic = 0 if ac023_ == 1
tab ac023_ energetic
* feel full of opportunities
gen opportunities = .
replace opportunities = 2 if ac024_ == 4
replace opportunities = 1 if ac024_ == 3
replace opportunities = 0.5 if ac024_ == 2
replace opportunities = 0 if ac024_ == 1
tab ac024_ opportunities
* future looks good
gen futurelook = .
replace futurelook = 2 if ac025_ == 4
replace futurelook = 1 if ac025_ == 3
replace futurelook = 0.5 if ac025_ == 2
replace futurelook = 0 if ac025_ == 1
tab ac025_ futurelook

gen mh_w8 = .
replace mh_w8 = outofcontrol + leftout + lookforw + lifemeaning + energetic + opportunities + futurelook
tab mh_w8

save "SCS_W8_OxGRT_models_WITH_VARS.dta", replace 

/* [FINAL SAVE OF FILE CALLED "SCS_W8_OxGRT_models_WITH_VARS.dta"]
* DEMOGRAPHIC
	* AGE
	gen age = age_int
	* GENDER
	tab gender if gender == 2
	gen female = (gender == 2)
	tab gender female
	* BORN IN COUNTRY 
	drop born_country
	gen born_country = .
	replace born_country = 1 if dn503_ == 1
	replace born_country = 0 if dn503_ == 5 | dn503_ == -1
	
	tab dn503_ born_country
	* BORN AS CITIZEN OF COUNTRY
	drop born_citizen
	gen born_citizen = .
	replace born_citizen = dn004_
	tab dn004_ 
		/// unify in a born_country_born citizen in single var?
		gen born_country_citizen = (born_country == 1 & born_citizen == 1)
	* RELATIONSHIP STATUS --> rel_status
	tab partner_var if partner_var == 0
	gen rel_status = (partner_var != 0)
	tab partner_var rel_status

	
* SOCIAL NETWORK
* general note: -9 "does not apply" includes people who did not name any alive siblings/parents/children since sn questions are administered on IF person alive = 1 conditions --> turning them into 0 is ok
	* CHILDREN IN SN
	tab childnet
	gen child_SN = childnet 
	replace child_SN = 0 if childnet == -9
	drop if childnet == -1 | childnet == -2
	tab child_SN childnet
	* SIBLINGS IN SN
	tab siblingnet
	gen sibling_SN = siblingnet
	replace sibling_SN = 0 if siblingnet == -9
	tab sibling_SN siblingnet
	* PARENTS IN SN
	tab parentnet
	gen parents_SN = parentnet
	replace parents_SN = 0 if parentnet == -9
	tab parentnet parents_SN
	* FRIENDS IN SN
	tab friendnet
	gen friends_SN = friendnet
	replace friends_SN = 0 if friendnet == -9
	tab friendnet friends_SN
	* FORMAL HELPERS IN SN
	tab formalnet
	gen helpers_SN = formalnet
	replace helpers_SN = 0 if formalnet == -9
	tab formalnet helpers_SN
	* OTHERS IN SN
	tab othernet
	gen others_SN = othernet
	replace others_SN = 0 if othernet == -9
	tab othernet others_SN
	* SN SIZE --> size discrepancy
	*tab sn_size_w8
	*egen size_SN = rowtotal(child_SN sibling_SN parents_SN friends_SN helpers_SN others_SN)
	*tab sn_size_w8 size_SN

* NOTE: from here, no substitution of -9 "does not apply", -2 "refusal", -2 "don't know" into 0s. These are turned into missing '.'.
	* SN SATISFACTION
	tab sn_satisfaction
	gen SN_satisf = sn_satisfaction
	replace SN_satisf = . if sn_satisfaction == -9 | sn_satisfaction == -2 | sn_satisfaction == -1
	tab sn_satisfaction SN_satisf
	* SN SOCIAL CONNECTEDNESS --> cannot be computed for 1831 individuals (missing info)
	tab sn_scale /* the higher, the more connected*/
	gen SN_connect = sn_scale
	replace SN_connect = . if sn_scale == -20 | sn_scale == -9
	tab sn_scale SN_connect
	* SN CONTACT --> also lots of missing info and does not apply
	tab contact_mean /* the higher the SN_contact, the more isolated */
	gen SN_contact = contact_mean
	replace SN_contact = . if contact_mean == -20 | contact_mean == -9 | contact_mean == -2 | contact_mean == -1 
	tab SN_contact
	* SN PROXIMITY
	tab prx_mean /* the higher the SN_proximity, the further spread out the SN is */
	gen SN_proximity = prx_mean
	replace SN_proximity = . if prx_mean == -20 | prx_mean == -9 | prx_mean == -2 | prx_mean == -1 
	tab SN_proximity
	* SN EMOTIONAL CLOSENESS
	tab close_mean /* the higher, the more emotionally close */
	gen SN_closeness = close_mean
	replace SN_closeness = . if close_mean == -20 | close_mean == -9 | close_mean == -2 | close_mean == -1
	tab SN_closeness

* SOCIOECONOMIC STATUS
	* TOTAL ANNUAL INCOME : FROM EMPL AND FROM SELF EMPL (AFTER TAX)
	* employment:
	tab ep205e if ep205e <10
	gen log_inc_empl = ln(ep205e) if ep205e > 0
	tab log_inc_empl if log_inc_empl < 1
	* self-employment:
	tab ep207e if ep207e <1000
	gen log_inc_self = ln(ep207e) if ep207e > 0
	* total income:
	gen log_inc_tot = ln(ep205e+ep207e) if ep205e > 0 & ep207e > 0
	
	* [CA] OVERALL MONTHLY INCOME BEFORE COVID
	tab cahh017e if cahh017e <10
	gen log_inc_pre_ca = ln(cahh017e) if cahh017e > 0
	tab log_inc_pre_ca if log_inc_pre_ca <1
	* MONEY OWED AMOUNT
	tab as055e if as055e < 1000
	gen log_owe_amount = ln(as055e) if as055e > 0
	tab as055e log_owe_amount if as055e < 5
	* YEARS OF EDUC
	tab dn041_ /* 7,472 individuals have this info */
	gen educ = dn041_ if dn041_ >= 0
	tab educ dn041_
	
* WORK & ECONOMIC
	* EMPLOYMENT STATUS --> -2 refusal, -1 don't know
	tab ep005_ if ep005_ == 1
	gen emp_retired = (ep005_ == 1)
	gen emp_employed = (ep005_ == 2)
	gen emp_unemployed = (ep005_ == 3 | ep005_ == 5)
	gen emp_sick_other = (ep005_ == 4 | ep005_ == 6)
	
	gen empl_status = (emp_employed == 1) /* 0 includes retired, disabled, homemaker, unemployed */
	* [CA] EMPLOYMENT STATUS AT BEGINNING OF PANDEMIC
	tab caep805_
	gen empl_status_pre_ca = (caep805_ == 1)
	replace empl_status_pre_ca = . if caep805_ == -2 | caep805_ == -1
	* [CA] LOST JOB DUE TO COVID --> not applicable turned to 0
	tab caw002_
	gen lost_job_ca = (caw002_ == 1)
	replace lost_job_ca = . if caw002_ == -1 | caw002_ == -2
	* INDUSTRY 
	tab ep018_
	gen industry = ep018_
	replace industry = . if ep018_ == -1 | ep018_ == -2
	tab ep018_ industry
	* [CA] JOB MODALITY SINCE OUTBREAK 
	tab caw010_
	gen job_flex_ca = (caw010_ == 1 | caw010_ == 3)
	replace job_flex_ca = . if caw010_ == -2 | caw010_ == -1 
	tab caw010_ job_flex_ca
	* CAN AFFORD UNEXPECTED EXPENSE
	tab co206_ if co206_ == -2
	gen unexpected_exp = (co206_ == 1)
	replace unexpected_exp = . if co206_ == -1 | co206_ == -2
	tab unexpected_exp co206_
	* CAN MAKE ENDS MEET --> the lower, the more difficulty
	tab co007_
	gen ends_meet = co007_
	replace ends_meet = . if co007_ == -1 | co007_ == -2
	tab ends_meet co007_
	* [CA] CAN MAKE ENDS MEET SINCE COVID
	* note: -9 "not applicable" is for individuals who are not first respondents in hh 
	* can retrieve info for the n.a. by using the family id? yes, partially:
		*step 1: copy var 
		tab caco007_
		gen caco007_new = caco007_
		replace caco007_new = 99 if caco007_ == -9
		replace caco007_new = 999 if caco007_ == -1 | caco007_ == -2
		tab caco007_new
		*step 2: sort
		sort hhid8 mergeid 
		*step 3: counter variable of people in hh that are interviewed
		bysort hhid8: gen counter = _n 
		*step 4: store first respondent answer in new var. missing values now represent people with -9.
		by hhid8: gen first_answer = caco007_ if counter == 1
		*step 5: missing values in new var 
		by hhid8: replace first_answer = first_answer[_n-1] if missing(first_answer)
		
		tab first_answer
		replace caco007_new = first_answer if caco007_ == -9
		tab caco007_new
		replace caco007_new = . if caco007_new == -9 | caco007_new == -1 | caco007_new == -2 | caco007_new == 999

	tab caco007_new 
	gen ends_meet_ca = caco007_new
	tab ends_meet_ca caco007_ /* coherent with co007_ in w8, multiple hh respondents values recuperated */

* PHYSICAL HEALTH
	* DIAGNOSED WITH LONG TERM CONDITION
	tab ph004_
	gen longterm_condition = (ph004_ == 1)
	replace longterm_condition = . if ph004_ == -1 | ph004_ == -2
	tab ph004_ longterm_condition
	* HOW MANY CHRONIC DISEASES
	tab chronicw8c
	gen conditions_count = chronicw8c
	replace conditions_count = . if chronicw8c == -1 | chronicw8c == -2
	tab conditions_count chronicw8c
	* [CA] HAS RECEIVED NEW DIAGNOSIS
	tab cah003_
	gen diagnosed_ca = (cah003_ == 1)
	replace diagnosed_ca = . if cah003_ == -1 | cah003_ == -2
	tab cah003_ diagnosed_ca
	* SELF RATED HEALTH
	tab ph003_ 
	gen health = ph003_ 
	replace health = . if ph003_ == -1 | ph003_ == -2
	tab ph003_ health 
	* HAS PAIN 
	tab ph084_
	gen pain = (ph084_ == 1)
	replace pain = . if ph084_ == -1 | ph084_ == -2
	tab ph084_ pain
	* LEVEL OF PAIN 
	tab ph085_
	gen pain_intensity = ph085_
	replace pain_intensity = . if ph085_ == -1 | ph085_ == -2
	tab ph085_ pain_intensity
	* HEARING AID
	tab ph046_
	gen hearing = ph046_
	replace hearing = . if ph046_ == -1 | ph046_ == -2
	tab ph046_ hearing
	* OTHER AIDS from ph059d1 to ph059d10, no, dot
	tab ph059d1 
	gen aids = 0
	replace aids = aids + 1 if ph059d1 == 1
	replace aids = aids + 1 if ph059d2 == 1
	replace aids = aids + 1 if ph059d3 == 1
	replace aids = aids + 1 if ph059d4 == 1
	replace aids = aids + 1 if ph059d5 == 1
	replace aids = aids + 1 if ph059d6 == 1
	replace aids = aids + 1 if ph059d7 == 1
	replace aids = aids + 1 if ph059d8 == 1
	replace aids = aids + 1 if ph059d9 == 1
	replace aids = aids + 1 if ph059d10 == 1
	replace aids = aids + 1 if ph059dot == 1
	tab aids ph059d1
	* SIGHT AIDS (glasses or contacts)
	tab ph041_
	gen sight = (ph041_ == 1)
	replace sight = . if ph041_ == -1 | ph041_ == -2
	tab ph041_ sight
	* BMI
	tab bmi2
	rename bmi bmi_specific
	gen bmi_cat = bmi2 
	replace bmi_cat = . if bmi2 == -3 | bmi2 == -2 | bmi2 == -1
	tab bmi2 bmi_cat
	* ADL
	tab adl
	gen adl_score = adl
	replace adl_score = . if adl == -1 | adl == -2
	tab adl_score
	* IADL
	tab iadl
	gen iadl_score = iadl 
	replace iadl_score = . if iadl == -1 | iadl == -2
	tab iadl_score
	* RECEIVES HEALTH FOR DIFFICULT ACTIVITIES
	tab ph050_
	gen help_act = (ph050_ == 1)
	replace help_act = . if ph050_ == -1 | ph050_ == -2
	tab ph050_ help_act
	* HELP RECEIVED IS EFFECTIVE
	tab ph051_
	gen help_efficacy = ph051_
	replace help_efficacy = . if ph051_ == -1 | help_efficacy == -2
	tab help_efficacy ph051_

* BEHAVIORAL RISK
	* SMOKES
	tab br002_
	gen smoker = (br002_ == 1)
	replace smoker = . if br002_ == -1 | br002_ == -2
	tab br002_ smoker
	* REGULAR ALCOHOL DRINKER
	tab br623_
	gen alcohol = (br623_ <= 4)
	replace alcohol = . if br623_ == -1 | br623_ == -2
	tab br623_ alcohol
	* PHYSICALLY INACTIVE
	tab phactiv
	gen sport = (phactiv == 0)
	replace sport = . if phactiv == -1 | phactiv == -2
	tab phactiv sport
	
* GEOGRAPHIC & LIVING CONDITIONS
	* URBAN OR RURAL
	/* note: frequency of answer is EXTREMELY low (254) */
	tab ho037_
	
	* COUNTRY
	tab country
	
	* OWNER, TENANT OR RENT FREE 
	tab ho002_
	gen home_owner = (ho002_ == 1)
	* NUMBER OF ROOMS IN ACCOMODATION
	tab ho032_
	
* COVID RELATED 
	* HAS GOTTEN FLU VACCINE
	tab hc884_
	gen flu_vax = (hc884_ == 1)
	replace flu_vax = . if hc884_ == -1 | hc884_ == -2
	tab flu_vax hc884_
	* [CA] RESPONDENT HAD SYMPTOMS
	tab cac003_1
	*note: -9 "n.a." means person answered no to them/anyone having had symptoms
	gen ca_symptoms = 0 
	replace ca_symptoms = 1 if cac003_1 == 1
	replace ca_symptoms = . if cac003_1 == -1 | cac003_1 == -2
	tab cac003_1 ca_symptoms 
	* [CA] SPOUSE HAD SYMPTOMS
	tab cac003_2
	gen ca_symp_spouse = 0
	replace ca_symp_spouse = 1 if cac003_2 == 1
	replace ca_symp_spouse = . if cac003_2 == -1 | cac003_2 == -2 
	tab cac003_2 ca_symp_spouse
	* [CA] PARENT HAD SYMPTOMS
	tab cac003_3
	gen ca_symp_parent = 0
	replace ca_symp_parent = 1 if cac003_3 == 1
	replace ca_symp_parent = . if cac003_3 == -1 | cac003_3 == -2
	tab ca_symp_parent
	* [CA] NUMBER OF CHILDREN WHO HAD SYMPTOMS 
	tab cac003_4b
	gen ca_symp_n_child = cac003_4b
	replace ca_symp_n_child = 0 if cac003_4b == -9 | cac003_4b == -2
	tab cac003_4b ca_symp_n_child
	drop if cac003_4b > 40 /* drops outliers and missing */
	* [CA] OTHER PEOPLE IN HH HAD SYMPTOMS
	tab cac003_5
	gen ca_symp_othershh = 0
	replace ca_symp_othershh = 1 if cac003_5 == 1
	tab cac003_5 ca_symp_othershh
	* [CA] RESPONDENT TESTED POSITIVE
	tab cac005_1
	gen ca_positive = 0
	replace ca_positive = 1 if cac005_1 == 1
	replace ca_positive = . if cac005_1 == -1 | cac005_1 == -2
	tab cac005_1 ca_positive
	* [CA] SPOUSE TESTED POSITIVE
	tab cac005_2
	gen ca_pos_spouse = 0
	replace ca_pos_spouse = 1 if cac005_2 == 1
	replace ca_pos_spouse = . if cac005_2 == -1 | cac005_2 == -2
	tab cac005_2 ca_pos_spouse
	* [CA] PARENTS TESTED POSITIVE
	tab cac005_3
	gen ca_pos_parent = 0 
	replace ca_pos_parent = 1 if cac005_3 == 1
	replace ca_pos_parent = . if cac005_3 == -1 | cac005_3 == -2
	tab cac005_3 ca_pos_parent
	* [CA] N OF CHILDREN WHO TESTED POSITIVE 
	tab cac005_4b
	drop if cac005_4b == 32 /* outlier */
	gen ca_pos_n_child = cac005_4b
	replace ca_pos_n_child = 0 if cac005_4b == -9
	replace ca_pos_n_child = . if cac005_4b == -2
	tab cac005_4b ca_pos_n_child
	
* PSYCHOLOGICAL
	* BIG 5 - EXTRAVERSION
	tab bfi10_extra
	* BIG 5 - AGREEABLENESS 
	tab bfi10_agree
	* BIG 5 - CONSCIENTIOUSNESS 
	tab bfi10_consc
	* BIG 5 - OPENNESS
	tab bfi10_open
	* BIG 5 - NEUROTICISM
	tab bfi10_neuro
	* SATISFIED WITH LIFE 
	tab ac012_
	gen life_satisf = ac012_
	replace life_satisf = . if ac012_ == -1 | ac012_ == -2
	tab ac012_ life_satisf

* COGNITIVE HEALTH
	* SELF RATED READING --> higher is worse
	tab cf001_ 
	gen reading = cf001_
	replace reading = . if cf001_ == -1 | cf001_ == -2
	tab cf001_ reading
	* SELF RATED WRITING --> higher is worse
	tab cf002_
	gen writing = cf002_ 
	replace writing = . if cf002_ == -1 | cf002_ == -2
	tab cf002_ writing
	* CAN ORIENT WRT DAY / MONTH / YEAR  --> smaller is worse
	tab orienti
	gen orientation = orienti
	* VERBAL FLUENCY
	tab cf010_
	gen verbal_test = cf010_
	replace verbal_test = . if cf010_ == -1 | cf010_ == -2
	tab cf010_ verbal_test
	* NUMERACY
	* note: only 7,482 
	tab numeracy
	gen numeracy_test = numeracy
	
* MORE MODEL SPECIFIC
	* DONE VOLUNTEERING OR CHARITY PAST 12M
	tab ac035d1
	gen volunteered_12m = (ac035d1 == 1)
	replace volunteered_12m = . if ac035d1 == -1 | ac035d1 == -2
	tab ac035d1 volunteered_12m
	* DONE SPORT, SOCIAL OR CLUBS PAST 12M
	tab ac035d5
	gen social_act_12m = (ac035d5 == 1)
	replace social_act_12m = . if ac035d5 == -1 | ac035d5 == -2
	tab ac035d5 social_act_12m
	* PARTICIPATED IN POLITICAL OR COMMUNITY ORG IN PAST 12M
	tab ac035d7
	gen community_12m = (ac035d7 == 1)
	replace community_12m = . if ac035d7 == -1 | ac035d7 == -2
	tab ac035d7 community_12m

	
save "SCS_W8_OxGRT_models_WITH_VARS.dta", replace
*/



*	*	*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 4.3: GENERATE ALL W8 RELEVANT VARIABLES	*
*	*	*	*	*	*	*	*	*	*	*	*	*	*
use "W8_OxGRT_models.dta", clear

* W8 MH INDEX FROM AC MODULE
*feel out of control 
gen outofcontrol = .
replace outofcontrol = 0 if ac015_ == 4
replace outofcontrol = 0.5 if ac015_ == 3
replace outofcontrol = 1 if ac015_ == 2
replace outofcontrol = 2 if ac015_ == 1
tab ac015_ outofcontrol
* feel left out of things
gen leftout = .
replace leftout = 0 if ac016_ == 4
replace leftout = 0.5 if ac016_ == 3
replace leftout = 1 if ac016_ == 2
replace leftout = 2 if ac016_ == 1
tab ac016_ leftout
* look forward to each day 
gen lookforw = .
replace lookforw = 2 if ac020_ == 4
replace lookforw = 1 if ac020_ == 3
replace lookforw = 0.5 if ac020_ == 2
replace lookforw = 0 if ac020_ == 1
tab ac020_ lookforw
* life has meaning 
gen lifemeaning = .
replace lifemeaning = 2 if ac021_ == 4
replace lifemeaning = 1 if ac021_ == 3
replace lifemeaning = 0.5 if ac021_ == 2
replace lifemeaning = 0 if ac021_ == 1
tab ac021_ lifemeaning
* feel full of energy 
gen energetic = .
replace energetic = 2 if ac023_ == 4
replace energetic = 1 if ac023_ == 3
replace energetic = 0.5 if ac023_ == 2
replace energetic = 0 if ac023_ == 1
tab ac023_ energetic
* feel full of opportunities
gen opportunities = .
replace opportunities = 2 if ac024_ == 4
replace opportunities = 1 if ac024_ == 3
replace opportunities = 0.5 if ac024_ == 2
replace opportunities = 0 if ac024_ == 1
tab ac024_ opportunities
* future looks good
gen futurelook = .
replace futurelook = 2 if ac025_ == 4
replace futurelook = 1 if ac025_ == 3
replace futurelook = 0.5 if ac025_ == 2
replace futurelook = 0 if ac025_ == 1
tab ac025_ futurelook

gen mh_w8 = .
replace mh_w8 = outofcontrol + leftout + lookforw + lifemeaning + energetic + opportunities + futurelook
tab mh_w8


tab empl_status

/* [FINAL SAVE OF FILE CALLED "W8_OxGRT_models_WITH_VARS.DTA"]
* DEMOGRAPHIC
	* AGE
	gen age = age_int
	* GENDER
	tab gender if gender == 2
	gen female = (gender == 2)
	tab gender female
	* BORN IN COUNTRY 
	*drop born_country
	gen born_country = .
	replace born_country = 1 if dn503_ == 1
	replace born_country = 0 if dn503_ == 5 | dn503_ == -1
	
	tab dn503_ born_country
	* BORN AS CITIZEN OF COUNTRY
	*drop born_citizen
	gen born_citizen = .
	replace born_citizen = dn004_
	tab dn004_ 
		* unify in a born_country_born citizen in single var?
		gen born_country_citizen = (born_country == 1 & born_citizen == 1)
	* RELATIONSHIP STATUS --> rel_status
	tab partner_var if partner_var == 0
	gen rel_status = (partner_var != 0)
	tab partner_var rel_status

	
* SOCIAL NETWORK
* general note: -9 "does not apply" includes people who did not name any alive siblings/parents/children since sn questions are administered on IF person alive = 1 conditions --> turning them into 0 is ok
	* CHILDREN IN SN
	tab childnet
	gen child_SN = childnet 
	replace child_SN = 0 if childnet == -9
	drop if childnet == -1 | childnet == -2
	tab child_SN childnet
	* SIBLINGS IN SN
	tab siblingnet
	gen sibling_SN = siblingnet
	replace sibling_SN = 0 if siblingnet == -9
	tab sibling_SN siblingnet
	* PARENTS IN SN
	tab parentnet
	gen parents_SN = parentnet
	replace parents_SN = 0 if parentnet == -9
	tab parentnet parents_SN
	* FRIENDS IN SN
	tab friendnet
	gen friends_SN = friendnet
	replace friends_SN = 0 if friendnet == -9
	tab friendnet friends_SN
	* FORMAL HELPERS IN SN
	tab formalnet
	gen helpers_SN = formalnet
	replace helpers_SN = 0 if formalnet == -9
	tab formalnet helpers_SN
	* OTHERS IN SN
	tab othernet
	gen others_SN = othernet
	replace others_SN = 0 if othernet == -9
	tab othernet others_SN
	* SN SIZE --> size discrepancy
	*tab sn_size_w8
	*egen size_SN = rowtotal(child_SN sibling_SN parents_SN friends_SN helpers_SN others_SN)
	*tab sn_size_w8 size_SN

* NOTE: from here, no substitution of -9 "does not apply", -2 "refusal", -2 "don't know" into 0s. These are turned into missing '.'.
	* SN SATISFACTION
	tab sn_satisfaction
	gen SN_satisf = sn_satisfaction
	replace SN_satisf = . if sn_satisfaction == -9 | sn_satisfaction == -2 | sn_satisfaction == -1
	tab sn_satisfaction SN_satisf
	* SN SOCIAL CONNECTEDNESS --> cannot be computed for 1831 individuals (missing info)
	tab sn_scale /* the higher, the more connected*/
	gen SN_connect = sn_scale
	replace SN_connect = . if sn_scale == -20 | sn_scale == -9
	tab sn_scale SN_connect
	* SN CONTACT --> also lots of missing info and does not apply
	tab contact_mean /* the higher the SN_contact, the more isolated */
	gen SN_contact = contact_mean
	replace SN_contact = . if contact_mean == -20 | contact_mean == -9 | contact_mean == -2 | contact_mean == -1 
	tab SN_contact
	* SN PROXIMITY
	tab prx_mean /* the higher the SN_proximity, the further spread out the SN is */
	gen SN_proximity = prx_mean
	replace SN_proximity = . if prx_mean == -20 | prx_mean == -9 | prx_mean == -2 | prx_mean == -1 
	tab SN_proximity
	* SN EMOTIONAL CLOSENESS
	tab close_mean /* the higher, the more emotionally close */
	gen SN_closeness = close_mean
	replace SN_closeness = . if close_mean == -20 | close_mean == -9 | close_mean == -2 | close_mean == -1
	tab SN_closeness

* SOCIOECONOMIC STATUS
	* TOTAL ANNUAL INCOME : FROM EMPL AND FROM SELF EMPL (AFTER TAX)
	* employment:
	tab ep205e if ep205e <10
	gen log_inc_empl = ln(ep205e) if ep205e > 0
	tab log_inc_empl if log_inc_empl < 1
	* self-employment:
	tab ep207e if ep207e <1000
	gen log_inc_self = ln(ep207e) if ep207e > 0
	* total income:
	gen log_inc_tot = ln(ep205e+ep207e) if ep205e > 0 & ep207e > 0

	* MONEY OWED AMOUNT
	tab as055e if as055e < 1000
	gen log_owe_amount = ln(as055e) if as055e > 0
	tab as055e log_owe_amount if as055e < 5
	* YEARS OF EDUC
	tab dn041_ /* 7,472 individuals have this info */
	gen educ = dn041_ if dn041_ >= 0
	tab educ dn041_
	
* WORK & ECONOMIC
	* EMPLOYMENT STATUS --> -2 refusal, -1 don't know
	tab ep005_ if ep005_ == 1
	gen emp_retired = (ep005_ == 1)
	gen emp_employed = (ep005_ == 2)
	gen emp_unemployed = (ep005_ == 3 | ep005_ == 5)
	gen emp_sick_other = (ep005_ == 4 | ep005_ == 6)
	
	gen empl_status = (emp_employed == 1) /* 0 includes retired, disabled, homemaker, unemployed */

	* INDUSTRY 
	tab ep018_
	gen industry = ep018_
	replace industry = . if ep018_ == -1 | ep018_ == -2
	tab ep018_ industry

	* CAN AFFORD UNEXPECTED EXPENSE
	tab co206_ if co206_ == -2
	gen unexpected_exp = (co206_ == 1)
	replace unexpected_exp = . if co206_ == -1 | co206_ == -2
	tab unexpected_exp co206_
	* CAN MAKE ENDS MEET --> the lower, the more difficulty
	tab co007_
	gen ends_meet = co007_
	replace ends_meet = . if co007_ == -1 | co007_ == -2
	tab ends_meet co007_

* PHYSICAL HEALTH
	* DIAGNOSED WITH LONG TERM CONDITION
	tab ph004_
	gen longterm_condition = (ph004_ == 1)
	replace longterm_condition = . if ph004_ == -1 | ph004_ == -2
	tab ph004_ longterm_condition
	* HOW MANY CHRONIC DISEASES
	tab chronicw8c
	gen conditions_count = chronicw8c
	replace conditions_count = . if chronicw8c == -1 | chronicw8c == -2
	tab conditions_count chronicw8c

	* SELF RATED HEALTH
	tab ph003_ 
	gen health = ph003_ 
	replace health = . if ph003_ == -1 | ph003_ == -2
	tab ph003_ health 
	* HAS PAIN 
	tab ph084_
	gen pain = (ph084_ == 1)
	replace pain = . if ph084_ == -1 | ph084_ == -2
	tab ph084_ pain
	* LEVEL OF PAIN 
	tab ph085_
	gen pain_intensity = ph085_
	replace pain_intensity = . if ph085_ == -1 | ph085_ == -2
	tab ph085_ pain_intensity
	* HEARING AID
	tab ph046_
	gen hearing = ph046_
	replace hearing = . if ph046_ == -1 | ph046_ == -2
	tab ph046_ hearing
	* OTHER AIDS from ph059d1 to ph059d10, no, dot
	tab ph059d1 
	gen aids = 0
	replace aids = aids + 1 if ph059d1 == 1
	replace aids = aids + 1 if ph059d2 == 1
	replace aids = aids + 1 if ph059d3 == 1
	replace aids = aids + 1 if ph059d4 == 1
	replace aids = aids + 1 if ph059d5 == 1
	replace aids = aids + 1 if ph059d6 == 1
	replace aids = aids + 1 if ph059d7 == 1
	replace aids = aids + 1 if ph059d8 == 1
	replace aids = aids + 1 if ph059d9 == 1
	replace aids = aids + 1 if ph059d10 == 1
	replace aids = aids + 1 if ph059dot == 1
	tab aids ph059d1
	* SIGHT AIDS (glasses or contacts)
	tab ph041_
	gen sight = (ph041_ == 1)
	replace sight = . if ph041_ == -1 | ph041_ == -2
	tab ph041_ sight
	* BMI
	tab bmi2
	rename bmi bmi_specific
	gen bmi_cat = bmi2 
	replace bmi_cat = . if bmi2 == -3 | bmi2 == -2 | bmi2 == -1
	tab bmi2 bmi_cat
	* ADL
	tab adl
	gen adl_score = adl
	replace adl_score = . if adl == -1 | adl == -2
	tab adl_score
	* IADL
	tab iadl
	gen iadl_score = iadl 
	replace iadl_score = . if iadl == -1 | iadl == -2
	tab iadl_score
	* RECEIVES HEALTH FOR DIFFICULT ACTIVITIES
	tab ph050_
	gen help_act = (ph050_ == 1)
	replace help_act = . if ph050_ == -1 | ph050_ == -2
	tab ph050_ help_act
	* HELP RECEIVED IS EFFECTIVE
	tab ph051_
	gen help_efficacy = ph051_
	replace help_efficacy = . if ph051_ == -1 | help_efficacy == -2
	tab help_efficacy ph051_

* BEHAVIORAL RISK
	* SMOKES
	tab br002_
	gen smoker = (br002_ == 1)
	replace smoker = . if br002_ == -1 | br002_ == -2
	tab br002_ smoker
	* REGULAR ALCOHOL DRINKER
	tab br623_
	gen alcohol = (br623_ <= 4)
	replace alcohol = . if br623_ == -1 | br623_ == -2
	tab br623_ alcohol
	* PHYSICALLY INACTIVE
	tab phactiv
	gen sport = (phactiv == 0)
	replace sport = . if phactiv == -1 | phactiv == -2
	tab phactiv sport
	
* GEOGRAPHIC & LIVING CONDITIONS
	* URBAN OR RURAL
	/* note: frequency of answer is EXTREMELY low (254) */
	tab ho037_
	
	* COUNTRY
	tab country
	
	* OWNER, TENANT OR RENT FREE 
	tab ho002_
	gen home_owner = (ho002_ == 1)
	* NUMBER OF ROOMS IN ACCOMODATION
	tab ho032_
	
* COVID RELATED 
	* HAS GOTTEN FLU VACCINE
	tab hc884_
	gen flu_vax = (hc884_ == 1)
	replace flu_vax = . if hc884_ == -1 | hc884_ == -2
	tab flu_vax hc884_

	
* PSYCHOLOGICAL
	* BIG 5 - EXTRAVERSION
	tab bfi10_extra
	* BIG 5 - AGREEABLENESS 
	tab bfi10_agree
	* BIG 5 - CONSCIENTIOUSNESS 
	tab bfi10_consc
	* BIG 5 - OPENNESS
	tab bfi10_open
	* BIG 5 - NEUROTICISM
	tab bfi10_neuro
	* SATISFIED WITH LIFE 
	tab ac012_
	gen life_satisf = ac012_
	replace life_satisf = . if ac012_ == -1 | ac012_ == -2
	tab ac012_ life_satisf

* COGNITIVE HEALTH
	* SELF RATED READING --> higher is worse
	tab cf001_ 
	gen reading = cf001_
	replace reading = . if cf001_ == -1 | cf001_ == -2
	tab cf001_ reading
	* SELF RATED WRITING --> higher is worse
	tab cf002_
	gen writing = cf002_ 
	replace writing = . if cf002_ == -1 | cf002_ == -2
	tab cf002_ writing
	* CAN ORIENT WRT DAY / MONTH / YEAR  --> smaller is worse
	tab orienti
	gen orientation = orienti
	* VERBAL FLUENCY
	tab cf010_
	gen verbal_test = cf010_
	replace verbal_test = . if cf010_ == -1 | cf010_ == -2
	tab cf010_ verbal_test
	* NUMERACY
	* note: only 7,482 
	tab numeracy
	gen numeracy_test = numeracy
	
* MORE MODEL SPECIFIC
	* DONE VOLUNTEERING OR CHARITY PAST 12M
	tab ac035d1
	gen volunteered_12m = (ac035d1 == 1)
	replace volunteered_12m = . if ac035d1 == -1 | ac035d1 == -2
	tab ac035d1 volunteered_12m
	* DONE SPORT, SOCIAL OR CLUBS PAST 12M
	tab ac035d5
	gen social_act_12m = (ac035d5 == 1)
	replace social_act_12m = . if ac035d5 == -1 | ac035d5 == -2
	tab ac035d5 social_act_12m
	* PARTICIPATED IN POLITICAL OR COMMUNITY ORG IN PAST 12M
	tab ac035d7
	gen community_12m = (ac035d7 == 1)
	replace community_12m = . if ac035d7 == -1 | ac035d7 == -2
	tab ac035d7 community_12m


save "W8_OxGRT_models_WITH_VARS.dta", replace
*/


*	*	*	*	*	*	*	*	*	*	*	*	*	*
*	STEP 4.4: GENERATE COVID_DEATH INSTRUMENT 		*
*	*	*	*	*	*	*	*	*	*	*	*	*	*
use "SCS_W8_OxGRT_models_WITH_VARS.dta", clear
/* DIFFERENT DEATHS HAVE DIFFERENT WEIGHTS: CLOSE FAMILY 4, FAMILY 3, ACQUAINTANCES 2, OTHERS 1
tab cac013_
gen covid_death = 0
drop if cac013_ == -1 | cac013_ == -2

* spouse or partner, parent, child 	--> heaviest on MH 		--> 4
* partner 
tab cac013_ cac014_2
gen death_partner = 0 
replace death_partner = 1 if cac014_2 == 1
* parents 
tab cac013_ cac014_3
tab cac014_3 cac014_3b
gen death_parents = 0
replace death_parents = 1 if cac014_3b == 1 
replace death_parents = 2 if cac014_3b == 2
* children 
tab cac013_ cac014_4
tab cac014_4 cac014_4b
gen death_children = 0 
replace death_children = 1 if cac014_4b == 1
replace death_children = 4 if cac014_4b == 4


* household member, other relative 	--> heavy on MH 		--> 3
* hh member 
tab cac013_ cac014_5
tab cac014_5 cac014_5b
gen death_hh = 0 
replace death_hh = 1 if cac014_5b == 1
replace death_hh = 2 if cac014_5b == 2
replace death_hh = 3 if cac014_5b == 3
* other relative non hh 
tab cac013_ cac014_6
tab cac014_6 cac014_6b
gen death_non_hh = 0
replace death_non_hh = 1 if cac014_6b == 1
replace death_non_hh = 2 if cac014_6b == 2
replace death_non_hh = 3 if cac014_6b == 3
replace death_non_hh = 4 if cac014_6b == 4
replace death_non_hh = 10 if cac014_6b == 10


* neighbor, friend or colleague 	--> less heavy on MH 	--> 2
tab cac013_ cac014_7
tab cac014_7 cac014_7b
gen death_neighbor_friend_colleague = 0
replace death_neighbor_friend_colleague = cac014_7b if cac014_7b != -9 & cac014_7b != -2
tab death_neighbor_friend_colleague cac014_7b
replace death_neighbor_friend_colleague = 1 if cac014_7b == -2

* caregiver or other 				--> least heavy on MH 	--> 1
* caregivers
tab cac013_ cac014_8
tab cac014_8 cac014_8b
gen death_caregiver = 0
replace death_caregiver = cac014_8b if cac014_8b != -9 & cac014_8b != -2
replace death_caregiver = 1 if cac014_8b == -2
* others 
tab cac013_ cac014_97
tab cac014_97 cac014_97b
gen death_other = 0 
replace death_other = cac014_97b if cac014_97b != -9 & cac014_97b != -2 
replace death_other = 1 if cac014_97b == -2


replace covid_death = (death_partner + death_parents + death_children)*4 + ///
						(death_hh + death_non_hh)*3 + ///
						(death_neighbor_friend_colleague)*2 + ///
						(death_caregiver + death_other)*1
tab covid_death
* drop outliers + missing 
drop if covid_death > 80
tab covid_death

save "SCS_W8_OxGRT_models_WITH_VARS.dta", replace 
*/






********************************************************************************
********************************************************************************
*					5 : MODELS ESTIMATION 	  	
********************************************************************************
********************************************************************************
*
*	*	*	*	*	*	*	*	*	*
*	5.1: SCS & W8 MODELS			*
*	*	*	*	*	*	*	*	*	*
* Notes:
*	-	for all models, generate the dependent variable 
* 	-	for all: simple probit, multiple probit, first stage reg, ivprobit reg 
use "SCS_W8_OxGRT_models_WITH_VARS.dta", clear

	*	*	*	*	*	*	*
*	REFINING MODELS		*
*	*	*	*	*	*	*

	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	*	5.1.3: REDUCED WORK HOURS SINCE PANDEMIC		*
	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	
	use "SCS_W8_OxGRT_models_WITH_VARS.dta", clear
	/* gen and save new educ var 
	gen isced97educ = isced1997_r
	drop if isced1997_r == 0 | isced1997_r == 97
	tab isced97educ isced1997_r
	
	save "SCS_W8_OxGRT_models_WITH_VARS.dta", replace
	*/
	
	
* DONE AND SAVED - RERUN FOR FIRST STAGE F STATS AND EXOGENEITY TESTS *
	* dependent : CONDITIONAL ON INDIVIDUAL BEING EMPLOYED AT THE START OF COVID 
	tab caw021_
	drop if caw021_ == -9 | caw021_ == -1 | caw021_ == -2
	gen reduced_hours = 0
	replace reduced_hours = 1 if caw021_ == 1
	tab reduced_hours caw021_
	tab reduced_hours
	* sample 9196 before vars 
	drop if empl_status == 1
	
	
	* SAMPLE INCLUDES ONLY PEOPLE WITH A JOB AT THE START OF THE PANDEMIC, WHO KEPT JOB THROUGH THE PANDEMIC
	tab lost_job_ca
	drop if lost_job_ca == 1
	
	
	
	* VARIABLE SELECTION
	/*
	probit reduced_hours ///
		mh_ca /// 
		age female born_country rel_status /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
		
	test longterm_condition health pain
	*/
	
	
	*********************
	*** SIMPLE PROBIT ***
	probit reduced_hours ///
		mh_ca ///
		, vce(robust)
	estimates store simple
	
	
	***********************
	*** MULTIPLE PROBIT ***
	probit reduced_hours ///
		mh_ca ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	keep if e(sample)
	
	tab reduced_hours
	estimates store multiple
	margins, dydx(*) predict(pr) level(90)
	
	tab country reduced_hours
	sum reduced_hours mh_ca ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport
	sum covid_death upto_month_avg_SI upto_month_avg_newcasesperm
	
*TO CHECK WHICH COUNTRIES IN WHICH SPECIFICATION
	keep if e(sample)
	tab country reduced_hours

	****************************
	*** FIRST STAGE : 1 INST ***
	regress mh_ca ///
		upto_month_avg_SI /// 1 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI
	estimates store FS2

		
	
	
	******************************
	*** SECOND STAGE : 1 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI) ///
		, vce(robust)
		
	estimates store IV3
	keep if e(sample)
	margins, dydx(*) predict(pr) level(90)
	
	
	*	*	*	*	ROBUSTNESS CHECKS 	*	*	*	*
	* REMOVE POTENTIALLY ENDOGENOUS VARIABLES
		ivprobit reduced_hours ///
		age female rel_status isced97educ /// 
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI) ///
		, vce(robust)
	estimates store secondstage
	
	
	regress mh_ca ///
		upto_month_avg_SI /// 1 instrument
		age female rel_status isced97educ ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI
	estimates store firststage

	outreg2 [secondstage firststage] using "robustness.xls", replace
	
	
	
	
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		upto_month_avg_SI upto_month_avg_newcasesperm /// 2 instrument
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI upto_month_avg_newcasesperm
	estimates store FS4
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI upto_month_avg_newcasesperm), two
		overid
		, vce(robust)
	estimates store IV5
	estat overid
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		upto_month_avg_SI covid_death /// 2 instrument
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI covid_death
	estimates store FS6
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI covid_death), vce(robust)
		overid
		, vce(robust)
	estimates store IV7
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		covid_death upto_month_avg_newcasesperm /// 2 instrument
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test covid_death upto_month_avg_newcasesperm
	estimates store FS8
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = covid_death upto_month_avg_newcasesperm) , two
		overid
		, vce(robust)
	estimates store IV9
	
	
	****************************
	*** FIRST STAGE : 3 INST ***
	*keep if female == 1
	
	
	regress mh_ca ///
		covid_death upto_month_avg_newcasesperm upto_month_avg_SI /// 3 instrument
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		, vce(robust)
	test covid_death upto_month_avg_newcasesperm upto_month_avg_SI
	estimates store FS10
	
	******************************
	*** SECOND STAGE : 3 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = covid_death upto_month_avg_newcasesperm upto_month_avg_SI) , two
		overid
		, vce(robust)
	estimates store IV11
	
	
	outreg2 [multiple FS2 IV3 FS4 IV5 FS6 IV7 FS8 IV9 FS10 IV11] using "M1RESULTS.xls", replace
	
	/*
	*******************************
	*** FIRST STAGE: 2 INST [ BUT NO CASES PER MILLION!! ]
	regress mh_ca ///
		covid_death upto_month_avg_SI /// 2 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI covid_death
	estimates store FS_2inst_nocases
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit reduced_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = covid_death upto_month_avg_SI ) ///
		, vce(robust)
	estimates store IVprobit_2inst_nocases
	
	
	*** EXPORT 
	outreg2 [simple multiple FS_1inst IVProbit_1inst FS_2inst IVprobit_2inst FS_2inst_nocases IVprobit_2inst_nocases FS_3inst IVProbit_3inst] using "scs_reduced_ivprobit.xls", replace
	
*/
	
	

	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	*	5.1.4: INCREASED WORK HOURS SINCE PANDEMIC		*
	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	use "SCS_W8_OxGRT_models_WITH_VARS.dta", clear
	
* DONE AND SAVED - RERUN FOR FIRST STAGE F TEST AND EXOGENEITY TESTS
	
	
	tab caw024_
	drop if caw024_ == -9 | caw024_ == -1 | caw024_ == -2
	gen increased_hours = 0
	replace increased_hours = 1 if caw024_ == 1
	tab increased_hours caw024_
	
	* SAMPLE INCLUDES ONLY PEOPLE WITH A JOB AT THE START OF THE PANDEMIC, WHO KEPT JOB THROUGH THE PANDEMIC
	tab lost_job_ca
	drop if lost_job_ca == 1
	
	
	*********************
	*** SIMPLE PROBIT ***
	probit increased_hours ///
		mh_ca ///
		, vce(robust)
	estimates store simple
	
	


	
	*********************************************************************************************
	***********************
	*** MULTIPLE PROBIT ***
	probit increased_hours ///
		mh_ca ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
		keep if e(sample)
	tab increased_hours
	estimates store multiple
	margins, dydx(*) predict(pr) level(90)
	
	tab country increased_hours
	sum increased_hours mh_ca ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport
	sum covid_death upto_month_avg_SI upto_month_avg_newcasesperm
	
*TO CHECK WHICH COUNTRIES IN WHICH SPECIFICATION
	keep if e(sample)
	tab country increased_hours

	****************************
	*** FIRST STAGE : 1 INST ***
	regress mh_ca ///
		upto_month_avg_SI /// 1 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI
	estimates store FS2
		
	
	
	******************************
	*** SECOND STAGE : 1 INSTR ***
	ivprobit increased_hours ///
		age female rel_status isced97educ ///  
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI) ///
		, vce(robust)
	estimates store IV3
	keep if e(sample)
	keep if empl_status == 1
	margins, dydx(*) predict(pr)
	
	*	*	*	*	ROBUSTNESS CHECKS 	*	*	*	*
	* REMOVE POTENTIALLY ENDOGENOUS VARIABLES
	ivprobit increased_hours ///
		age female rel_status isced97educ /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI) ///
		, vce(robust)
	estimates store secondstage
	
	
	regress mh_ca ///
		upto_month_avg_SI /// 1 instrument
		age female rel_status isced97educ ///
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI
	estimates store firststage

	outreg2 [secondstage firststage] using "robustness.xls", replace
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		upto_month_avg_SI upto_month_avg_newcasesperm /// 2 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI upto_month_avg_newcasesperm
	estimates store FS4
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit increased_hours ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI upto_month_avg_newcasesperm) , two
		overid
		, vce(robust)
	estimates store IV5

	
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		upto_month_avg_SI covid_death /// 2 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test upto_month_avg_SI covid_death
	estimates store FS6
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit increased_hours ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_SI covid_death), two
		overid
		, vce(robust)
	estimates store IV7
	
	
	****************************
	*** FIRST STAGE : 2 INST ***
	regress mh_ca ///
		upto_month_avg_newcasesperm covid_death /// 2 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport, vce(robust)
	test covid_death upto_month_avg_newcasesperm
	estimates store FS8
		
	
	
	******************************
	*** SECOND STAGE : 2 INSTR ***
	ivprobit increased_hours ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = upto_month_avg_newcasesperm covid_death), two
		overid
		, vce(robust)
	estimates store IV9
	
	
	
	****************************
	*** FIRST STAGE : 3 INST ***
	*keep if female == 1
	
	
	regress mh_ca ///
		covid_death upto_month_avg_newcasesperm upto_month_avg_SI /// 3 instrument
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		, vce(robust)
	test covid_death upto_month_avg_newcasesperm upto_month_avg_SI
	estimates store FS10
	
	******************************
	*** SECOND STAGE : 3 INSTR ***
	ivprobit increased_hours ///
		age female rel_status isced97educ /// 
		SN_contact SN_proximity SN_closeness /// 
		child_SN sibling_SN parents_SN friends_SN others_SN /// 
		log_inc_pre_ca job_flex_ca ///
		ends_meet_ca ///
		diagnosed_ca ca_symptoms ///
		longterm_condition health pain ///
		bmi_cat flu_vax iadl_score /// 
		smoker alcohol sport ///
		(mh_ca = covid_death upto_month_avg_newcasesperm upto_month_avg_SI), two
		overid
		, vce(robust)
	estimates store IV11
	
	
	outreg2 [multiple FS2 IV3 FS4 IV5 FS6 IV7 FS8 IV9 FS10 IV11] using "M2RESULTS.xls", replace
	
	*** EXPORT 
	outreg2 [simple multiple FS_1inst IVProbit_1inst FS_2inst IVprobit_2inst FS_3inst IVProbit_3inst] using "scs_increased_ivprobit.xls", replace
	
*/



