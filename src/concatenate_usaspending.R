#Defines function "concatenate_usaspending" to bring contracts and grants data together

concat_usaspending <- function(pattern) {
  files <- list.files(path = file.path(temp_path), pattern = pattern, full.names = T)
  tables <- lapply(files, read.csv, header = T)
  tables = tables[-3]
  return(do.call(rbind, tables))
}