        case 
          when WS_WORK_INTERACTIONS_DY_ID = 201
          then 1
          when WS_WORK_INTERACTIONS_DY_ID = 202
          then 3
          when WS_WORK_INTERACTIONS_DY_ID = 221
          then 5
          else 0
        end work_days,


       case when OCC_WORKING_ID = 127 then 1 else 0 end any_work,
	   
	
        case 
          when WS_WKPL_FREQ_CHANGE_EST_ID = 241
          then 1
          when WS_WKPL_FREQ_CHANGE_EST_ID = 242
          then 3
          when WS_WKPL_FREQ_CHANGE_EST_ID = 243
          then 4
          when WS_WKPL_FREQ_CHANGE_EST_ID = 261
          then 5
          else 0
        end freq_work_increase,
   
    case 
        when instr(':' || OCC_JOBS_IDS || ':', ':178:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':161:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':139:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':164:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':163:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':137:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':140:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':162:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':46:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':621:') > 0
        then 1
        else 0
    end job_high_risk,

    case 
        when instr(':' || OCC_JOBS_IDS || ':', ':174:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':176:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':131:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':179:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':165:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':168:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':132:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':134:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':136:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':130:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':133:') > 0
        or instr(':' || OCC_JOBS_IDS || ':', ':171:') > 0
        then 1
        else 0
    end job_low_risk,

        case 
          when WS_WORK_INTERACTIONS_DY_ID = 584 -- b/t 1-10 ppl day
          then 1
          when WS_WORK_INTERACTIONS_DY_ID = 585 -- b/t 11-30 ppl day
          then 2
          when WS_WORK_INTERACTIONS_DY_ID = 586 -- b/t 31-50 ppl day
          then 3
          when WS_WORK_INTERACTIONS_DY_ID = 587 -- 51 or over ppl day
          then 4
          else 0 -- "no one"
        end n_work_interactions,


        case 
          when (instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':285:')
          + instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':286:')
          + instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':287:')
          + instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':288:')
          + instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':289:')
          + instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':290:')) = 0
		  AND instr(':' || WS_WORK_INTERACTIONS_DY_ID || ':', ':584:') > 0 -- wfh
          then 1
          else 0 
        end wfh_only,


       case when WS_WKPL_SCL_DIS_MEAS_ID = 266 then 1 else 0 end work_unsafe_distance,

       case when WS_WKPL_SCL_DIS_MEAS_ID = 282 then 1 else 0 end work_unsafe_masks,


    case 
      when instr(':' || LS_DWELLINGS_IDS || ':', ':143:') > 0 -- Long-term care facility
      or instr(':' || LS_DWELLINGS_IDS || ':', ':144:') > 0 -- Long-term care facility
      or instr(':' || LS_DWELLINGS_IDS || ':', ':145:') > 0 -- Assisted-living facility
      or instr(':' || LS_DWELLINGS_IDS || ':', ':146:') > 0 -- Dormitory
      or instr(':' || LS_DWELLINGS_IDS || ':', ':148:') > 0 -- RV / Trailer
      or instr(':' || LS_DWELLINGS_IDS || ':', ':149:') > 0 -- Shelter
      or instr(':' || LS_DWELLINGS_IDS || ':', ':150:') > 0 -- Other adult group setting
      or instr(':' || LS_DWELLINGS_IDS || ':', ':153:') > 0 -- Tribal Lands / Reservation
      then 1
      else 0
    end risky_home_setting,

		least((nvl(LS_COHAB_UNDER_18, 0)), 8) AS n_home_young,

		least((nvl(LS_COHAB_BTW_18_64, 0)), 8) AS n_home_middle,

		least((nvl(LS_COHAB_OVER_64, 0)), 8) AS n_home_older,

       case when LS_COHAB_EXP_RTN_SCH_ID = 381 then 1 else 0 end home_schoolreturn,

		least((nvl(LS_COHAB_IN_SCH_OR_CC, 0)), 8) AS outside_childcare,

    case 
      when instr(':' || LS_COHAB_JOBS_IDS || ':', ':317:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':160:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':158:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':303:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':302:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':326:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':159:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':301:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':47:') > 0
      or instr(':' || LS_COHAB_JOBS_IDS || ':', ':623:') > 0
      then 1
      else 0  --Check vs Blythe's coding
    end high_partner_risk,


        case 
          when CI_HOME_VISITOR_FREQ_ID = 361
          then 2
          when CI_HOME_VISITOR_FREQ_ID = 362
          then 1
          else 0
        end freq_visitors,



       case when CI_GATHERINGS_LAST_2W_ID = 341 then 1 else 0 end social_gathering,
	   
        case 
          when CI_INTERACTIONS_DY_ID = 588
          then -1
          when CI_INTERACTIONS_DY_ID = 589
          then 0
          when CI_INTERACTIONS_DY_ID = 590
          then 1
          when CI_INTERACTIONS_DY_ID = 591
          then 2
          when CI_INTERACTIONS_DY_ID = 592
          then 3
          else 0 --Check with Blythe
        end n_social_intxn,

        case 
          when CI_INTERACTIONS_DY_ID = 344
          then 1
          when CI_INTERACTIONS_DY_ID = 345
          then 2
          when CI_INTERACTIONS_DY_ID = 346
          then 3
          else 0
        end n_gathering,


       case when instr(':' || CI_GATHERINGS_LOCATION_ID || ':', ':347:') + instr(':' || CI_GATHERINGS_LOCATION_ID || ':', ':601:') > 0 then 1 else 0 end indoor_gathering,
	   
      case when instr(':' || WS_WORK_TRANSPORTATION_IDS || ':', ':290:') > 0 then 1 else 0 end travel_plane,

      case when instr(':' || WS_WORK_TRANSPORTATION_IDS || ':', ':287:') > 0 then 1 else 0 end travel_bus,

      case when instr(':' || WS_WORK_TRANSPORTATION_IDS || ':', ':288:') > 0 then 1 else 0 end travel_train,


       case when MD_AGE < 40 then 1 else 0 end age_18,

       case when MD_AGE >= 40 and MD_AGE < 50 then 1 else 0 end age_40,

       case when MD_AGE >= 50 and MD_AGE < 60 then 1 else 0 end age_50,


       case when MD_AGE >= 60 and MD_AGE < 70 then 1 else 0 end age_60,

       case when MD_AGE >= 70 and MD_AGE < 80 then 1 else 0 end age_70,

       case when MD_AGE >= 80 then 1 else 0 end age_80,

       case when instr(':' || MD_ETHNICITY_IDS || ':', ':40:') > 0 then 1 else 0 end race_black,


       case when instr(':' || MD_ETHNICITY_IDS || ':', ':43:') > 0 then 1 else 0 end hispanic,


	MD_WEIGHT*0.453592 / POWER(((MD_HEIGHT_FT*12 + MD_HEIGHT_IN)*0.0254),2) AS bmi,
  
	case when (MD_WEIGHT*0.453592 / POWER(((MD_HEIGHT_FT*12 + MD_HEIGHT_IN)*0.0254),2)) >=25
	and (MD_WEIGHT*0.453592 / POWER(((MD_HEIGHT_FT*12 + MD_HEIGHT_IN)*0.0254),2)) < 30 then 1 else 0
	end bmi_overweight, 

	case when (MD_WEIGHT*0.453592 / POWER(((MD_HEIGHT_FT*12 + MD_HEIGHT_IN)*0.0254),2)) >=30
	then 1 else 0
	end bmi_obese, 

       case when instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':549:') > 0 then 1 else 0 end co_asthma,


       case when instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':560:') > 0 then 1 else 0 end co_cancer_hx,

       case when instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':561:') > 0 then 1 else 0 end cancer,

    (instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':1:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':2:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':3:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':4:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':547:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':548:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':549:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':550:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':551:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':552:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':554:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':555:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':556:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':557:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':558:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':559:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':560:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':561:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':562:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':563:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':564:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':565:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':566:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':567:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':568:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':569:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':570:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':81:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':82:') +
    instr(':' || CSS_PRE_EXISTING_COND_IDS || ':', ':83:')) AS comorbidity_n,
	-- ineligant; maybe count ":"s or use regex list instead
