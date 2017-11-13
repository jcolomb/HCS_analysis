library(osfr)
osfr::login("i3sOvWDaZD0Xz9vJudKSn4ZHIJuAIDelnOxwUhMv9mqmTOf63sKvQwy4yDISuCgObOxVzO")
a=read.csv(PMeta)
PMeta ="data/Projects_metadata.csv"

upload_files("myxcv", PMeta)

id="myxcv"

config <- get_config(FALSE)
url_osf <- construct_link(paste0('guids/', id))
call <- httr::GET(url_osf, config)
res <- process_json(call)

b=read.csv( path_file("myxcv"))
path_file(id)

osfr::logout()
