#Defines function "filter_usaspending" 

filter_usaspending <- function(file_name, state, columns, out_name) {
  read.csv(file.path(temp_path, file_name))  %>%
    filter(primary_place_of_performance_state_name == state) %>%
    filter(!(federal_action_obligation == 0)) %>%
    select(all_of(columns)) %>%
    write.csv((file.path(temp_path, out_name)), row.names = F)
  }