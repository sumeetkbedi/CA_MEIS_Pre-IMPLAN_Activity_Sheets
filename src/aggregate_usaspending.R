#Defines function "statewide_aggregate" for aggregating USAspending and DOE spending data into each IMPLAN code for the state

statewide_aggregate <- function(dataframe, out_name) {
  dataframe %>%
    group_by(implan_code) %>%
    summarize(spending = sum(spending)) %>%
    filter(!is.na(spending) & spending != 0) %>%
    write.csv(file.path(temp_path, out_name), row.names = F)
}