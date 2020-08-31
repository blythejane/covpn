# source from covpn_registry_analysis.Rmd
# insert ORE SQL query string

ore.connect("", host="", 
            password="", 
            service_name="", all=TRUE)

score_summary_query = "[insert query string here]"

ore.sync(query = c("score_summary_query_result" = score_summary_query))

oracle_production <- data.frame(score_summary_query_result)

hist(oracle_production$SCORE_ENDPOINT, breaks = 50)
