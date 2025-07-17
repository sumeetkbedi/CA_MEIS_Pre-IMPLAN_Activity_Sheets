#Define function "t1_check" to error check USAspending data - TIER 1

t1_check <- function(df1, clean_path, error_path) {
  t1_ind <- which(!is.na(df1$recipient_county_name) & !is.na(df1$recipient_congressional_district) & !(df1$recipient_congressional_district %in% c(0,90)) & (df1$recipient_congressional_district < 100) & !is.na(df1$implan_code))
  if(length(t1_ind)>0) {
    write.table(df1[t1_ind,], clean_path, append = file.exists(clean_path), col.names = !file.exists(clean_path), row.names = FALSE, sep = ",")
    val <- (df1[-t1_ind,])
    } 
  else {
    val <- df1
  }
  write.csv(val, file.path(error_path), row.names = FALSE)
  return(val)
}
