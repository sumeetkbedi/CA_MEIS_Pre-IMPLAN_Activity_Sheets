#Define function "t1_check" to error check USAspending data - TIER 1

t1_check <- function(df, clean_path, error_path) {
  t1_ind <- which(!is.na(df$recipient_county_name) & !is.na(df$recipient_congressional_district) &
                  !(df$recipient_congressional_district %in% c(0,90)) & (df$recipient_congressional_district < 100) &
                  !is.na(df$implan_code))
  if(length(t1_ind) > 0) {
    write.table(df[t1_ind,], clean_path, append = file.exists(clean_path), col.names = !file.exists(clean_path), row.names = F, sep = ",")
    val <- (df[-t1_ind,])
    } 
  else {
    val <- df
  }
  write.csv(val, file.path(error_path), row.names = F)
  return(val)
}