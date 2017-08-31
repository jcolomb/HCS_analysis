dataread.c <- function() {
  name <- tclvalue(tkgetOpenFile(
    filetypes = "{ {XLSX Files} {.xlsx} } { {All Files} * }"))
  if (name == "")
    return(data.frame()) # Return an empty data frame if no file was selected
  
  
  data <- read_xlsx(name,sheet = 2)
  assign("data", data, envir = .GlobalEnv)
  assign("name",name, envir = .GlobalEnv)
  cat("The lookup data was imported successfully.\n
      Please close the file selection by pressing the OK Button")
}