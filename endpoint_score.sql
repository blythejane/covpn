-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

SELECT 1


WITH responses_clean AS (
  SELECT
    sr_guid
    , CASE 
        WHEN CRD_RNA_TEST_RESULT='Positive'
          OR CRD_ANTI_TEST_RESULT='Positive'
        THEN 0
        ELSE 1 
      END AS susceptible
    , CASE 
        WHEN WS_WKPL_FREQ_ID=181 THEN 0 -- 'Not at all'
        WHEN WS_WKPL_FREQ_ID=201 THEN 1 -- '1 day a week'
        WHEN WS_WKPL_FREQ_ID=202 THEN 3 -- '2 to 4 days a week'
        WHEN WS_WKPL_FREQ_ID=221 THEN 5 -- '5 or more days a week'
        ELSE 0
      END AS freq_work
    , CASE 
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=241 THEN 1 -- 'Yes, increase by 25% per month over the next 3 months'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=242 THEN 3 -- 'Yes, increase by 50% per month over the next 3 months'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=243 THEN 4 -- 'Yes, increase by 75% per month over the next 3 months'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=261 THEN 5 -- 'Yes, increase by 100% per month over the next 3 months'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=262 THEN 0 -- 'No'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=263 THEN 0 -- 'I don't know'
        WHEN WS_WKPL_FREQ_CHANGE_EST_ID=264 THEN 0 -- 'Not Applicable'
        ELSE 0
      END AS freq_work_increase
    , CASE 
        WHEN WS_WORK_INTERACTIONS_DY_ID=583 THEN 0 -- 'No one'
        WHEN WS_WORK_INTERACTIONS_DY_ID=584 THEN 1 -- 'Between 1 and 10 people'
        WHEN WS_WORK_INTERACTIONS_DY_ID=585 THEN 2 -- 'Between 11 and 30 people'
        WHEN WS_WORK_INTERACTIONS_DY_ID=586 THEN 3 -- 'Between 31 and 50 people'
        WHEN WS_WORK_INTERACTIONS_DY_ID=587 THEN 4 -- 'More than 50 people'
        ELSE 0
      END AS n_work_interactions
    , CASE
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':178:')>0 THEN 1 -- childcare
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':161:')>0 THEN 1 -- social services
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':139:')>0 THEN 1 -- dental
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':164:')>0 THEN 1 -- factory
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':163:')>0 THEN 1 -- food
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':137:')>0 THEN 1 -- healtworker
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':140:')>0 THEN 1 -- personal
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':162:')>0 THEN 1 -- protective
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':46:')>0 THEN 1 -- transit
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':621:')>0 THEN 1 -- tourism
        ELSE 0
      END AS job_risk_high
    , CASE
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':174:')>0 THEN 1 -- architect
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':176:')>0 THEN 1 -- art
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':131:')>0 THEN 1 -- business
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':179:')>0 THEN 1 -- laborer
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':165:')>0 THEN 1 -- farmer
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':168:')>0 THEN 1 -- grounds
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':132:')>0 THEN 1 -- IT
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':134:')>0 THEN 1 -- legal
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':136:')>0 THEN 1 -- research
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':130:')>0 THEN 1 -- management
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':133:')>0 THEN 1 -- office
        WHEN INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':171:')>0 THEN 1 -- warehouse
        ELSE 0
      END AS job_risk_low
    , CASE 
        WHEN WS_WKPL_SCL_DIS_MEAS_ID=266 THEN 1 -- "No"
        ELSE 0
      END AS work_unsafe_distance
    , CASE 
        WHEN WS_WKPL_PPE_USAGE_ID=282 THEN 1 -- "No"
        ELSE 0
      END AS work_unsafe_masks
    , CASE 
        WHEN (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':53:')>0) -- 'Work from home'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':285:')=0) -- 'Carpool'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':286:')=0) -- 'Rideshare (Taxi, Uber, Lyft, others)'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':287:')=0) -- 'Bus'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':288:')=0) -- 'Train / Subway'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':289:')=0) -- 'Walk / Bike'
          AND (INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':290:')=0) -- 'Frequent Air Travel'
        THEN 1
        ELSE 0
      END AS wfh_only
    , CASE
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':143:')>0 THEN 1 -- 'Multi-family housing (apartment building, condo)'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':144:')>0 THEN 1 -- 'Long-term care facility'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':145:')>0 THEN 1 -- 'Assisted-living facility'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':146:')>0 THEN 1 -- 'Dormitory'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':148:')>0 THEN 1 -- 'Single room in a hotel'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':149:')>0 THEN 1 -- 'Shelter'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':150:')>0 THEN 1 -- 'Other adult group setting'
        WHEN INSTR(CONCAT(':',LS_DWELLINGS_IDS,':'),':153:')>0 THEN 1 -- 'Tribal Lands / Reservation'
        ELSE 0
      END AS risky_home_setting
    , CASE
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':317:')>0 THEN 1 -- 'Child Care Facility'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':160:')>0 THEN 1 -- 'Community and Social Services'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':158:')>0 THEN 1 -- 'Dental or Orthodontic'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':303:')>0 THEN 1 -- 'Factory for Food Processing and Production (Meat Packing)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':302:')>0 THEN 1 -- 'Food Preparation and Service Related (Restaurant, Coffee Shop)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':326:')>0 THEN 1 -- 'Healthcare Worker (Doctor, Nurse, Technician, Specialist)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':159:')>0 THEN 1 -- 'Personal Care and Personal Services (Hair or Nail Salon, Personal Trainer)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':301:')>0 THEN 1 -- 'Protective Services and First Responders (Law Enforcement, EMT, Fire/Rescue)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':47:')>0 THEN 1 -- 'Public Transportation (Transit Worker, Bus Driver, Subway Attendant)'
        WHEN INSTR(CONCAT(':',LS_COHAB_JOBS_IDS,':'),':623:')>0 THEN 1 -- 'Travel and Tourism (Airline Flight Crew, Tour Guide)'
        ELSE 0
      END AS high_partner_risk
    , CASE
        WHEN ISNULL(LS_COHAB_UNDER_18) THEN 0
        WHEN LS_COHAB_UNDER_18>8 THEN 8
        ELSE LS_COHAB_UNDER_18
      END AS n_home_young
    , CASE
        WHEN ISNULL(LS_COHAB_BTW_18_64) THEN 0
        WHEN LS_COHAB_BTW_18_64>8 THEN 8
        ELSE LS_COHAB_BTW_18_64
      END AS n_home_middle
    , CASE
        WHEN ISNULL(LS_COHAB_OVER_64) THEN 0
        WHEN LS_COHAB_OVER_64>8 THEN 8
        ELSE LS_COHAB_OVER_64
      END AS n_home_older
    , CASE
        WHEN LS_COHAB_EXP_RTN_SCH_ID=381 THEN 1 -- 'Yes'
        ELSE 0
      END AS home_schoolreturn
    , CASE
        WHEN ISNULL(LS_COHAB_IN_SCH_OR_CC) THEN 0
        WHEN LS_COHAB_IN_SCH_OR_CC>8 THEN 8
        ELSE LS_COHAB_IN_SCH_OR_CC
      END AS outside_childcare
    , CASE
        WHEN ((LS_COHAB_OVER_64+LS_COHAB_UNDER_18)>=1)
              AND ((INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':53:')>0) -- WFH
                   OR (INSTR(CONCAT(':',OCC_JOBS_IDS,':'),':180:')>0) -- Home Based Business or Stay-at-Home Caregiver
                   OR (WS_WKPL_FREQ_ID=181) -- 'Not at all'
                   )
        THEN 1
        ELSE 0
      END AS caregiver
    , CASE 
        WHEN CI_HOME_VISITOR_FREQ_ID=48 THEN 0 -- 'Never'
        WHEN CI_HOME_VISITOR_FREQ_ID=49 THEN 0 -- 'N/A'
        WHEN CI_HOME_VISITOR_FREQ_ID=361 THEN 2 -- 'Daily'
        WHEN CI_HOME_VISITOR_FREQ_ID=362 THEN 1 -- 'Weekly'
        WHEN CI_HOME_VISITOR_FREQ_ID=363 THEN 0 -- 'Monthly'
        WHEN CI_HOME_VISITOR_FREQ_ID=364 THEN 0 -- 'Rarely'
        ELSE 0
      END AS freq_visitors
    , CASE 
        WHEN CI_GATHERINGS_LAST_2W_ID=341 THEN 1 -- 'Yes'
        ELSE 0
      END AS social_gathering
    , CASE 
        WHEN CI_INTERACTIONS_DY_ID=588 THEN 0 -- 'No one'
        WHEN CI_INTERACTIONS_DY_ID=589 THEN 5 -- 'Between 1 and 10 people'
        WHEN CI_INTERACTIONS_DY_ID=590 THEN 20 -- 'Between 11 and 30 people'
        WHEN CI_INTERACTIONS_DY_ID=591 THEN 40 -- 'Between 31 and 50 people'
        WHEN CI_INTERACTIONS_DY_ID=592 THEN 75 -- 'More than 50 people'
        ELSE 0
      END AS n_social_intxn
    , CASE 
        WHEN CI_GATHERINGS_PEOPLE_ID=343 THEN 15 -- 'Between 10 and 20 people'
        WHEN CI_GATHERINGS_PEOPLE_ID=344 THEN 35 -- 'Between 21 and 50 people'
        WHEN CI_GATHERINGS_PEOPLE_ID=345 THEN 150 -- 'Between 51 and 250 people'
        WHEN CI_GATHERINGS_PEOPLE_ID=346 THEN 300 -- 'More than 250 people'
        ELSE 0
      END AS n_gathering
    , CASE 
        WHEN ISNULL(CI_GATHERINGS_LOCATION_ID) THEN 0
        WHEN CI_GATHERINGS_LOCATION_ID IN (347, 601) THEN 1 -- Indoor; Both
        ELSE 0.25
      END AS gathering_risk
    , CASE 
        WHEN INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':287:')>0 THEN 1 -- 'Bus'
        WHEN INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':288:')>0 THEN 1 -- 'Train / Subway'
        WHEN INSTR(CONCAT(':',WS_WORK_TRANSPORTATION_IDS,':'),':290:')>0 THEN 1 -- 'Frequent Air Travel'
        ELSE 0
      END AS travel_public_transit
    , CASE 
        WHEN INSTR(CONCAT(':',MD_ETHNICITY_IDS,':'),':40:')>0 THEN 1 -- 'Black or African American'
        ELSE 0
      END AS race_black
    , CASE 
        WHEN INSTR(CONCAT(':',MD_ETHNICITY_IDS,':'),':43:')>0 THEN 1 -- 'Hispanic or Latino'
        ELSE 0
      END AS hispanic
    , RISK_SCORE_COVER_H AS risk_score_cover_h
    , MD_AGE AS md_age
    , CASE 
        WHEN MD_AGE<40 THEN 1
        ELSE 0
      END AS age_18
    , CASE 
        WHEN (MD_AGE<50 AND MD_AGE>=40) THEN 1
        ELSE 0
      END AS age_40
    , CASE 
        WHEN (MD_AGE<60 AND MD_AGE>=50) THEN 1
        ELSE 0
      END AS age_50
    , CASE 
        WHEN (MD_AGE<70 AND MD_AGE>=60) THEN 1
        ELSE 0
      END AS age_60
    , CASE 
        WHEN (MD_AGE<80 AND MD_AGE>=70) THEN 1
        ELSE 0
      END AS age_70
    , CASE 
        WHEN (MD_AGE>=80) THEN 1
        ELSE 0
      END AS age_80
    , CASE 
        WHEN (MD_AGE>=80) THEN 1
        ELSE 0
      END AS age_80
    , CASE
        WHEN ((MD_WEIGHT*0.453592)/(POWER(MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)>=25)
              AND ((MD_WEIGHT*0.453592)/(POWER(MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)<30)
        THEN 1
        ELSE 0
      END AS bmi_overweight
    , CASE
        WHEN ((MD_WEIGHT*0.453592)/(POWER(MD_HEIGHT_FT*12+MD_HEIGHT_IN*0.0254),2)>=30) THEN 1
        ELSE 0
      END AS bmi_obese
    , ISNULL((CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':1:')>0) THEN 1 ELSE 0 END -- "Hospitalized in the last 6 months"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':2:')>0) THEN 1 ELSE 0 END -- "Immunocompromising or immunosuppressive condition"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':3:')>0) THEN 1 ELSE 0 END --  "History of allergic reaction to any vaccine (including rash, hives or trouble breathing)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':4:')>0) THEN 1 ELSE 0 END -- "Other serious chronic illness"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':547:')>0) THEN 1 ELSE 0 END -- "A history of smoking or vaping"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':548:')>0) THEN 1 ELSE 0 END -- "Currently smoking or vaping"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':549:')>0) THEN 1 ELSE 0 END -- "Asthma"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':550:')>0) THEN 1 ELSE 0 END -- "COPD (emphysema)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':551:')>0) THEN 1 ELSE 0 END -- "Pulmonary fibrosis"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':552:')>0) THEN 1 ELSE 0 END -- "Cystic fibrosis"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':554:')>0) THEN 1 ELSE 0 END -- "Heart arrhythmia (AFib, irregular heartbeat)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':555:')>0) THEN 1 ELSE 0 END -- "Cardiomyopathy (enlarged heart)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':556:')>0) THEN 1 ELSE 0 END -- "Heart disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':557:')>0) THEN 1 ELSE 0 END -- "Hypertension (high blood pressure)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':558:')>0) THEN 1 ELSE 0 END -- "Congestive heart failure"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':559:')>0) THEN 1 ELSE 0 END -- "Stroke, TIA, or cerebrovascular disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':560:')>0) THEN 1 ELSE 0 END -- "Cancer - completed treatment"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':561:')>0) THEN 1 ELSE 0 END -- "Cancer - undergoing treatment"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':562:')>0) THEN 1 ELSE 0 END -- "Diabetes (type 1, started in childhood)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':563:')>0) THEN 1 ELSE 0 END -- "Diabetes (type 2, typically beginning as an adult but may be in younger people)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':564:')>0) THEN 1 ELSE 0 END -- "HIV/AIDS"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':565:')>0) THEN 1 ELSE 0 END -- "Inflammatory bowel disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':566:')>0) THEN 1 ELSE 0 END -- "Multiple sclerosis"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':567:')>0) THEN 1 ELSE 0 END -- "Arthritis (rheumatoid)"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':568:')>0) THEN 1 ELSE 0 END -- "Other autoimmune disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':569:')>0) THEN 1 ELSE 0 END -- "Kidney disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':570:')>0) THEN 1 ELSE 0 END -- "Liver disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':81:')>0) THEN 1 ELSE 0 END -- "Coronary artery disease"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':82:')>0) THEN 1 ELSE 0 END -- "Sickle cell anemia"
              +CASE WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':83:')>0) THEN 1 ELSE 0 END -- "Neurologic conditions, such as dementia"
              ),0) 
      AS comorbidity_n
    , CASE 
        WHEN (INSTR(CONCAT(':',CSS_PRE_EXISTING_COND_IDS,':'),':561:')>0) THEN 1 -- 'Cancer - undergoing treatment'
        ELSE 0
      END AS cancer
  FROM survey_responses_pivot_mv 
  WHERE sr_status in ('COMPLETED', 'ENROLLED')
    )   


WITH exposure_dimension_risk_scores AS (
  SELECT 
    sr_guid AS sr_guid
    , (CASE 
        WHEN full_home_score>=15
        THEN 15
        ELSE full_home_score
      END)/15 AS score_home 
    , (CASE 
        WHEN ISNULL(full_work_score) THEN 0
        WHEN full_work_score>=20 THEN 20
        ELSE full_work_score
       END)/20 AS score_work
    , (CASE 
        WHEN full_score_community>=15
        THEN 15
        ELSE full_score_community
      END)/15 AS score_community
    , CASE 
        WHEN travel_public_transit>0
        THEN 1
        ELSE 0
      END AS score_transit
  FROM (
    SELECT
      /*
      or_risky_home = 5.0
      or_school_childcare = 3.0
      or_caregiver = 1.3
      or_partner_job = 1.5
      or_job_risk_high = 2.0
      or_job_risk_low = 0.5
      or_wfh = 0.01
      or_work_unsafe_distance = 2.0
      or_work_unsafe_masks = 2.0
      or_gathering_risk = 3.0
      or_race_black = 5.0
      or_hispanic = 5.0
      */ 
      (POWER(5.0,risky_home_setting)
       *POWER(1.3,caregiver) 
       *(n_home_young*POWER(3.0,(home_schoolreturn+outside_childcare)) 
          +(n_home_middle+n_home_older)*POWER(1.5,high_partner_risk) 
          +freq_visitors)) AS full_home_score
      , ((social_gathering*n_gathering*POWER(3.0,gathering_risk)+n_social_intxn) 
         *POWER(5.0,race_black) 
         *POWER(5.0,hispanic)) AS full_score_community
      , ((freq_work+freq_work_increase)
         *n_work_interactions
         *POWER(2.0,job_risk_high)
         *POWER(0.5,job_risk_low)
         *POWER(2.0,work_unsafe_distance)
         *POWER(2.0,work_unsafe_masks)
         *POWER(0.01,wfh_only)) AS full_work_score
      , travel_public_transit AS travel_public_transit
    FROM responses_clean
    ) AS full_scores
)


WITH exposures AS (
  SELECT 
    e.sr_guid AS sr_guid
    , r.susceptible AS susceptible
    , e.score_home AS score_home 
    , e.score_work AS score_work
    , e.score_community AS score_community
    , e.score_transit AS score_transit
    /*
    beta_home = 0.2
    beta_work = 0.3
    beta_community = 0.4
    beta_transit = 0.1
    */ 
    , ROUND((0.2*e.score_home
            +0.3*e.score_work
            +0.4*e.score_community
            +0.1*e.score_transit)*100
            , 0) AS score_cumulative_exposure
    , r.risk_score_cover_h AS risk_score_cover_h
  FROM exposure_dimension_risk_scores AS e
  JOIN responses_clean AS r  
    ON e.sr_guid=r.sr_guid
)


WITH clinical AS (
  SELECT
  r.sr_guid AS sr_guid
  , EXP(l.logistic) / (1+EXP(l.logistic)) AS p_clinical
  , 100-r.md_age AS score_control
  FROM responses_clean AS r
  JOIN (
    SELECT 
      sr_guid,
      /* 
      p_clinical_age18 = 0.33
      p_clinical_age40 = 0.40
      p_clinical_age50 = 0.49
      p_clinical_age60 = 0.63
      p_clinical_age70 = 0.69
      p_clinical_age80 = 0.69
      or_race_black = 5
      or_hispanic = 5
      or_bmi_overweight = 1.5
      or_bmi_obese = 3
      or_comorbidity_n = 1.6
      or_cancer = 3
      */ 
      ((LOG(0.33/(1-0.33)))*age_18
       +(LOG(0.40/(1-0.40)))*age_40
       +(LOG(0.49/(1-0.49)))*age_50
       +(LOG(0.63/(1-0.63)))*age_60
       +(LOG(0.69/(1-0.69)))*age_70
       +(LOG(0.69/(1-0.69)))*age_80 
       +LOG(5.0)*race_black
       +LOG(5.0)*hispanic
       +LOG(1.5)*bmi_overweight
       +LOG(3.0)*bmi_obese
       +LOG(1.6)*comorbidity_n
       +LOG(1.6)*(comorbidity_n*age_80)^2
       +LOG(3.0)*cancer) AS logistic
      FROM responses_clean
    ) AS l
    ON r.sr_guid = l.sr_guid
)


WITH score_summary AS (
  SELECT 
    sr_guid AS sr_guid
    , susceptible AS susceptible
    , score_home AS score_home
    , score_work AS score_work
    , score_community AS score_community
    , score_transit AS score_transit
    , score_cumulative_exposure AS score_cumulative_exposure
    , risk_score_cover_h AS risk_score_cover_h
    , p_clinical AS p_clinical
    , score_control AS score_control
    , score_endpoint AS score_endpoint
    , CASE 
        WHEN ISNULL(score_endpoint) THEN "Low"
        WHEN score_endpoint>=36 THEN "High"
        WHEN (score_endpoint>=19 AND score_endpoint<36) THEN "Moderate"
        ELSE "Low"
      END AS endpoint_score_level
  FROM (
    SELECT
      e.sr_guid
      , e.susceptible
      , e.score_home
      , e.score_work
      , e.score_community
      , e.score_transit
      , e.score_cumulative_exposure
      , e.risk_score_cover_h
      , c.p_clinical
      . c.score_control
      , (e.score_cumulative_exposure
          /* w_clinical = 0.2 */ 
           *POWER(c.p_clinical,0.2)
           *e.susceptible) AS score_endpoint
    FROM exposures AS e
    JOIN clinical AS c
      ON e.sr_guid=c.sr_guid
      ) AS score_summary_sub
  )


WITH response_predictions AS (
  SELECT 
    r.*,
    s.*
  FROM responses_clean AS r
  JOIN score_summary AS s
    ON r.sr_guid=s.sr_guid
)

