#Define function "contract_check" for parsing through construction NAICS codes and parsing them out by keywords

contract_check <- function(patterns, data){
  val <- rep(FALSE, length(data))
  if(is.character(patterns)){
    for(i in 1:length(patterns)){
      val <- val | grepl(patterns[i], data, ignore.case = TRUE)
    }
  } else {
    stop('pattern must be a character vector')
  }
  return(val)
}