#Build framework for mandatory filters first
body = list(
  filters = list(
    agencies = data.frame(
      type = agency_type,
      tier = agency_tier,
      name = agency_name
    ),
    date_type = date_type,
    date_range = list(start_date = date_range_start,
                      end_date = date_range_end)
  ),
  file_format = "csv" 
)

#Check for Optional Filters, add to framework if found
if(exists("awards")){
  body$filters[["prime_award_types"]] <- awards
}

#Check and add location filters
if(length(ls(pattern = "recipient_locations")) > 0){
  location_list <- vector(mode = "list", length = 0)
  
  for(locations in ls(pattern = "recipient_locations")){
    location_list[[gsub("recipient_locations_", "", locations)]] <- get(locations)
  }
  
  body$filters[["recipient_locations"]] <- do.call(cbind.data.frame, location_list)

}

#Format filter body 
toJSON(body, pretty = T)

#Post query to API
request <- POST(
  "https://api.usaspending.gov/api/v2/bulk_download/awards/",
  body = body,
  encode = "json",
  verbose()
)

#Wait for file download to be prepared by site
Sys.sleep(5)
if(request$status_code == 200){
  status_check <- GET(url = content(request)$status_url)
  
  while(content(status_check)$status == "running"){
    print("System is still preparing the download link")
    Sys.sleep(30)
    status_check <- GET(url = content(request)$status_url)
  }
  
  file_url <- content(request)$file_url
}

#Set download file path
download_path = file.path(temp_path, content(request)$file_name)

#Download file to download file path
download.file(file_url, destfile = download_path)

#Unzip file for use
unzip(download_path, exdir = temp_path)

#Delete un-necessary files after completion
unlink(download_path)