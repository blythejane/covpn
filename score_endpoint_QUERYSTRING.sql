"SELECT sr_guid AS sr_guid , susceptible AS susceptible , score_home AS score_home , score_work AS score_work , score_community AS score_community , score_cumulative_exposure AS score_cumulative_exposure , risk_score_cover_h AS risk_score_cover_h , p_clinical AS p_clinical , score_control AS score_control , score_endpoint AS score_endpoint , CASE  WHEN score_endpoint IS NULL THEN 'Low' WHEN score_endpoint>=40 THEN 'High' WHEN (score_endpoint>=19 AND score_endpoint<40) THEN 'Moderate' ELSE 'Low' END AS endpoint_score_level FROM ( SELECT sr_guid AS sr_guid , susceptible AS susceptible , score_home AS score_home , score_work AS score_work , score_community AS score_community , score_cumulative_exposure AS score_cumulative_exposure , risk_score_cover_h AS risk_score_cover_h , p_clinical AS p_clinical , score_control AS score_control , (score_cumulative_exposure *POWER(p_clinical,0.2) *susceptible) AS score_endpoint FROM( SELECT  sr_guid AS sr_guid , susceptible AS susceptible , score_home AS score_home  , score_work AS score_work , score_community AS score_community , ROUND((0.3*score_home +0.4*score_work +0.3*score_community)*100 , 0) AS score_cumulative_exposure , risk_score_cover_h AS risk_score_cover_h , p_clinical AS p_clinical , score_control AS score_control FROM ( SELECT  sr_guid AS sr_guid , susceptible AS susceptible , (CASE  WHEN full_home_score>=15 THEN 15 ELSE full_home_score END)/15 AS score_home  , (CASE  WHEN full_work_score IS NULL THEN 0 WHEN full_work_score>=20 THEN 20 ELSE full_work_score END)/20 AS score_work , CASE  WHEN full_score_community>1 THEN 1 ELSE full_score_community END AS score_community , risk_score_cover_h AS risk_score_cover_h , (EXP(logistic) / (1+EXP(logistic))) AS p_clinical , (100-md_age) AS score_control FROM ( SELECT sr_guid AS sr_guid , susceptible AS susceptible , risk_score_cover_h AS risk_score_cover_h , md_age AS md_age , (POWER(5.0,risky_home_setting) *POWER(1.3,caregiver)  *(n_home_young*POWER(3.0,(home_schoolreturn+outside_childcare))  +(n_home_middle+n_home_older)*POWER(1.5,high_partner_risk)  +freq_visitors)) AS full_home_score , ((social_intxn_bw_1to10*0.25 +gathering_bw_10to20*0.5*POWER(indoor_gathering,1.5) +social_intxn_over10*0.9 +gathering_over20*0.9*POWER(indoor_gathering,1.5) +freq_visitors*0.2) *POWER(5.0,race_black)*POWER(5.0,hispanic)) AS full_score_community , ((freq_work+freq_work_increase) *(n_work_interactions+travel_public_transit) *POWER(2.0,job_risk_high) *POWER(0.5,job_risk_low) *POWER(2.0,work_unsafe_distance) *POWER(2.0,work_unsafe_masks) *POWER(0.1,wfh_only)) AS full_work_score , (LN((0.33/(1-0.33)))*age_18 +LN((0.40/(1-0.40)))*age_40 +LN((0.49/(1-0.49)))*age_50 +LN((0.63/(1-0.63)))*age_60 +LN((0.69/(1-0.69)))*age_70 +LN(0.69/(1-0.69))*age_80  +LN(5.0)*race_black +LN(5.0)*hispanic +LN(1.5)*bmi_overweight +LN(3.0)*bmi_obese +LN(1.6)*comorbidity_n +LN(1.6)*POWER((comorbidity_n*age_80),2) +LN(3.0)*cancer) AS logistic FROM ( SELECT SR_GUID , CASE  WHEN CRD_RNA_TEST_RESULT='Positive' OR CRD_ANTI_TEST_RESULT='Positive' THEN 0 ELSE 1  END AS susceptible , CASE  WHEN WS_WKPL_FREQ_ID=181 THEN 0  WHEN WS_WKPL_FREQ_ID=201 THEN 1 WHEN WS_WKPL_FREQ_ID=202 THEN 3 WHEN WS_WKPL_FREQ_ID=221 THEN 5 ELSE 0 END AS freq_work , CASE  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=241 THEN 1  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=242 THEN 3  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=243 THEN 4  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=261 THEN 5  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=262 THEN 0  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=263 THEN 0  WHEN WS_WKPL_FREQ_CHANGE_EST_ID=264 THEN 0  ELSE 0 END AS freq_work_increase , CASE  WHEN WS_WORK_INTERACTIONS_DY_ID=583 THEN 0  WHEN WS_WORK_INTERACTIONS_DY_ID=584 THEN 1  WHEN WS_WORK_INTERACTIONS_DY_ID=585 THEN 2  WHEN WS_WORK_INTERACTIONS_DY_ID=586 THEN 3 WHEN WS_WORK_INTERACTIONS_DY_ID=587 THEN 4 ELSE 0 END AS n_work_interactions , CASE WHEN INSTR(':' || OCC_JOBS_IDS || ':',':178:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':161:')>0 THEN 1 WHEN INSTR(':' || OCC_JOBS_IDS || ':',':139:')>0 THEN 1 WHEN INSTR(':' || OCC_JOBS_IDS || ':',':164:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':163:')>0 THEN 1 WHEN INSTR(':' || OCC_JOBS_IDS || ':',':137:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':140:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':162:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':46:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':621:')>0 THEN 1  ELSE 0 END AS job_risk_high , CASE WHEN INSTR(':' || OCC_JOBS_IDS || ':',':174:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':176:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':131:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':179:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':165:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':168:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':132:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':134:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':136:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':130:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':133:')>0 THEN 1  WHEN INSTR(':' || OCC_JOBS_IDS || ':',':171:')>0 THEN 1  ELSE 0 END AS job_risk_low , CASE  WHEN WS_WKPL_SCL_DIS_MEAS_ID=266 THEN 1 ELSE 0 END AS work_unsafe_distance , CASE  WHEN WS_WKPL_PPE_USAGE_ID=282 THEN 1 ELSE 0 END AS work_unsafe_masks , CASE  WHEN (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':53:')>0) AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':285:')=0)  AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':286:')=0)  AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':287:')=0)  AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':288:')=0)  AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':289:')=0)  AND (INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':290:')=0)  THEN 1 ELSE 0 END AS wfh_only , CASE WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':143:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':144:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':145:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':146:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':148:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':149:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':150:')>0 THEN 1  WHEN INSTR(':' || LS_DWELLINGS_IDS || ':',':153:')>0 THEN 1  ELSE 0 END AS risky_home_setting , CASE WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':317:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':160:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':158:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':303:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':302:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':326:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':159:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':301:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':47:')>0 THEN 1  WHEN INSTR(':' || LS_COHAB_JOBS_IDS || ':',':623:')>0 THEN 1  ELSE 0 END AS high_partner_risk , CASE WHEN LS_COHAB_UNDER_18 IS NULL THEN 0 WHEN LS_COHAB_UNDER_18>8 THEN 8 ELSE LS_COHAB_UNDER_18 END AS n_home_young , CASE WHEN LS_COHAB_BTW_18_64 IS NULL THEN 0 WHEN LS_COHAB_BTW_18_64>8 THEN 8 ELSE LS_COHAB_BTW_18_64 END AS n_home_middle , CASE WHEN LS_COHAB_OVER_64 IS NULL THEN 0 WHEN LS_COHAB_OVER_64>8 THEN 8 ELSE LS_COHAB_OVER_64 END AS n_home_older , CASE WHEN LS_COHAB_EXP_RTN_SCH_ID=381 THEN 1  ELSE 0 END AS home_schoolreturn , CASE WHEN LS_COHAB_IN_SCH_OR_CC IS NULL THEN 0 WHEN LS_COHAB_IN_SCH_OR_CC>3 THEN 3 ELSE LS_COHAB_IN_SCH_OR_CC END AS outside_childcare , CASE WHEN ((LS_COHAB_OVER_64+LS_COHAB_UNDER_18)>=1) AND ((INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':53:')>0)  OR (INSTR(':' || OCC_JOBS_IDS || ':',':180:')>0) OR (WS_WKPL_FREQ_ID=181)  ) THEN 1 ELSE 0 END AS caregiver , CASE  WHEN CI_HOME_VISITOR_FREQ_ID=48 THEN 0  WHEN CI_HOME_VISITOR_FREQ_ID=49 THEN 0  WHEN CI_HOME_VISITOR_FREQ_ID=361 THEN 2 WHEN CI_HOME_VISITOR_FREQ_ID=362 THEN 1  WHEN CI_HOME_VISITOR_FREQ_ID=363 THEN 0  WHEN CI_HOME_VISITOR_FREQ_ID=364 THEN 0  ELSE 0 END AS freq_visitors , CASE  WHEN CI_GATHERINGS_LAST_2W_ID=341 THEN 1  ELSE 0 END AS social_gathering , CASE  WHEN CI_INTERACTIONS_DY_ID=588 THEN 0  WHEN CI_INTERACTIONS_DY_ID=589 THEN 5  WHEN CI_INTERACTIONS_DY_ID=590 THEN 20  WHEN CI_INTERACTIONS_DY_ID=591 THEN 40  WHEN CI_INTERACTIONS_DY_ID=592 THEN 75  ELSE 0 END AS n_social_intxn , CASE  WHEN CI_GATHERINGS_PEOPLE_ID=343 THEN 15  WHEN CI_GATHERINGS_PEOPLE_ID=344 THEN 35  WHEN CI_GATHERINGS_PEOPLE_ID=345 THEN 150  WHEN CI_GATHERINGS_PEOPLE_ID=346 THEN 300  ELSE 0 END AS n_gathering , CASE  WHEN CI_GATHERINGS_LOCATION_ID IS NULL THEN 0 WHEN CI_GATHERINGS_LOCATION_ID IN (347, 601) THEN 1  ELSE 0.25 END AS gathering_risk , CASE  WHEN CI_INTERACTIONS_DY_ID=589 THEN 1  ELSE 0 END AS social_intxn_bw_1to10 , CASE  WHEN CI_INTERACTIONS_DY_ID IN (590, 591, 592) THEN 1  ELSE 0 END AS social_intxn_over10 , CASE  WHEN CI_GATHERINGS_PEOPLE_ID=343 THEN 1  ELSE 0 END AS gathering_bw_10to20 , CASE  WHEN CI_GATHERINGS_PEOPLE_ID IN (344, 345, 346) THEN 1  ELSE 0 END AS gathering_over20 , CASE  WHEN CI_INTERACTIONS_DY_ID IN (590, 591, 592) THEN 1 WHEN CI_GATHERINGS_PEOPLE_ID IN (344, 345, 346) THEN 1  ELSE 0 END AS social_risk_high , CASE  WHEN CI_GATHERINGS_LOCATION_ID IN (347, 601) THEN 1 ELSE 0 END AS indoor_gathering , CASE  WHEN INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':287:')>0 THEN 1  WHEN INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':288:')>0 THEN 1  WHEN INSTR(':' || WS_WORK_TRANSPORTATION_IDS || ':',':290:')>0 THEN 1  ELSE 0 END AS travel_public_transit , CASE  WHEN INSTR(':' || MD_ETHNICITY_IDS || ':',':40:')>0 THEN 1  ELSE 0 END AS race_black , CASE  WHEN INSTR(':' || MD_ETHNICITY_IDS || ':',':43:')>0 THEN 1  ELSE 0 END AS hispanic , RISK_SCORE_COVER_H AS risk_score_cover_h , MD_AGE AS md_age , CASE  WHEN MD_AGE<40 THEN 1 ELSE 0 END AS age_18 , CASE  WHEN (MD_AGE<50 AND MD_AGE>=40) THEN 1 ELSE 0 END AS age_40 , CASE  WHEN (MD_AGE<60 AND MD_AGE>=50) THEN 1 ELSE 0 END AS age_50 , CASE  WHEN (MD_AGE<70 AND MD_AGE>=60) THEN 1 ELSE 0 END AS age_60 , CASE  WHEN (MD_AGE<80 AND MD_AGE>=70) THEN 1 ELSE 0 END AS age_70 , CASE  WHEN (MD_AGE>=80) THEN 1 ELSE 0 END AS age_80 , CASE WHEN ((MD_WEIGHT*0.453592)/POWER((MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)>=25) AND ((MD_WEIGHT*0.453592)/POWER((MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)<25) THEN 1 ELSE 0 END AS bmi_overweight , CASE WHEN ((MD_WEIGHT*0.453592)/POWER((MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)>=30) THEN 1 ELSE 0 END AS bmi_obese , NVL((CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':1:')>0) THEN 1 ELSE 0 END +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':2:')>0) THEN 1 ELSE 0 END +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':3:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':4:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':547:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':548:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':549:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':550:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':551:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':552:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':554:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':555:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':556:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':557:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':558:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':559:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':560:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':561:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':562:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':563:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':564:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':565:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':566:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':567:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':568:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':569:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':570:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':81:')>0) THEN 1 ELSE 0 END +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':82:')>0) THEN 1 ELSE 0 END  +CASE WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':83:')>0) THEN 1 ELSE 0 END  ),0)  AS comorbidity_n , CASE  WHEN (INSTR(':' || CSS_PRE_EXISTING_COND_IDS || ':',':561:')>0) THEN 1  ELSE 0 END AS cancer FROM survey_responses_pivot_mv  WHERE sr_status in ('COMPLETED', 'ENROLLED') ) ) exposures_and_clinical ) scores ) scores_summary)"
