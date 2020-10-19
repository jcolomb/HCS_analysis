#ANALYSING DATA



# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
setwd("../")

versions =list.files("../.git/refs/tags")
if (length(versions) == 0) {versions =list.files("../tags")}
version = versions[length(versions)]
library(shiny)
library(plotly)
require (shinyFiles)
library (rstatix) #effect size calculation
library (coin) #effect size calculation
#setwd("analysis")
##multidimensional analysis:
library (randomForest)
library (ica)
library (e1071) #svm
require(Hmisc)   #binomial confidence 

#library(osfr) ##access to osf

#normal libraries:
library (tidyverse)
library (stringr)
#for plotting
library(gridExtra)
library(RGraphics)
source ("Rcode/functions.r")

source <- function (file, local = TRUE, echo = verbose, print.eval = echo, 
          exprs, spaced = use_file, verbose = getOption("verbose"), 
          prompt.echo = getOption("prompt"), max.deparse.length = 150, 
          width.cutoff = 60L, deparseCtrl = "showAttributes", chdir = FALSE, 
          encoding = getOption("encoding"), continue.echo = getOption("continue"), 
          skip.echo = 0, keep.source = getOption("keep.source")) 
{
  envir <- if (isTRUE(local)) 
    parent.frame()
  else if (identical(local, FALSE)) 
    .GlobalEnv
  else if (is.environment(local)) 
    local
  else stop("'local' must be TRUE, FALSE or an environment")
  if (!missing(echo)) {
    if (!is.logical(echo)) 
      stop("'echo' must be logical")
    if (!echo && verbose) {
      warning("'verbose' is TRUE, 'echo' not; ... coercing 'echo <- TRUE'")
      echo <- TRUE
    }
  }
  if (verbose) {
    cat("'envir' chosen:")
    print(envir)
  }
  if (use_file <- missing(exprs)) {
    ofile <- file
    from_file <- FALSE
    srcfile <- NULL
    if (is.character(file)) {
      have_encoding <- !missing(encoding) && encoding != 
        "unknown"
      if (identical(encoding, "unknown")) {
        enc <- utils::localeToCharset()
        encoding <- enc[length(enc)]
      }
      else enc <- encoding
      if (length(enc) > 1L) {
        encoding <- NA
        owarn <- options(warn = 2)
        for (e in enc) {
          if (is.na(e)) 
            next
          zz <- file(file, encoding = e)
          res <- tryCatch(readLines(zz, warn = FALSE), 
                          error = identity)
          close(zz)
          if (!inherits(res, "error")) {
            encoding <- e
            break
          }
        }
        options(owarn)
      }
      if (is.na(encoding)) 
        stop("unable to find a plausible encoding")
      if (verbose) 
        cat(gettextf("encoding = \"%s\" chosen", encoding), 
            "\n", sep = "")
      if (file == "") {
        file <- stdin()
        srcfile <- "<stdin>"
      }
      else {
        filename <- file
        file <- file(filename, "r", encoding = encoding)
        on.exit(close(file))
        if (isTRUE(keep.source)) {
          lines <- readLines(file, warn = FALSE)
          on.exit()
          close(file)
          srcfile <- srcfilecopy(filename, lines, file.mtime(filename)[1], 
                                 isFile = TRUE)
        }
        else {
          from_file <- TRUE
          srcfile <- filename
        }
        loc <- utils::localeToCharset()[1L]
        encoding <- if (have_encoding) 
          switch(loc, `UTF-8` = "UTF-8", `ISO8859-1` = "latin1", 
                 "unknown")
        else "unknown"
      }
    }
    else {
      lines <- readLines(file, warn = FALSE)
      srcfile <- if (isTRUE(keep.source)) 
        srcfilecopy(deparse(substitute(file)), lines)
      else deparse(substitute(file))
    }
    exprs <- if (!from_file) {
      if (length(lines)) 
        .Internal(parse(stdin(), n = -1, lines, "?", 
                        srcfile, encoding))
      else expression()
    }
    else .Internal(parse(file, n = -1, NULL, "?", srcfile, 
                         encoding))
    on.exit()
    if (from_file) 
      close(file)
    if (verbose) 
      cat("--> parsed", length(exprs), "expressions; now eval(.)ing them:\n")
    if (chdir) {
      if (is.character(ofile)) {
        if (grepl("^(ftp|http|file)://", ofile)) 
          warning("'chdir = TRUE' makes no sense for a URL")
        else if ((path <- dirname(ofile)) != ".") {
          owd <- getwd()
          if (is.null(owd)) 
            stop("cannot 'chdir' as current directory is unknown")
          on.exit(setwd(owd), add = TRUE)
          setwd(path)
        }
      }
      else {
        warning("'chdir = TRUE' makes no sense for a connection")
      }
    }
  }
  else {
    if (!missing(file)) 
      stop("specify either 'file' or 'exprs' but not both")
    if (!is.expression(exprs)) 
      exprs <- as.expression(exprs)
  }
  Ne <- length(exprs)
  if (echo) {
    sd <- "\""
    nos <- "[^\"]*"
    oddsd <- paste0("^", nos, sd, "(", nos, sd, nos, sd, 
                    ")*", nos, "$")
    trySrcLines <- function(srcfile, showfrom, showto) {
      tryCatch(suppressWarnings(getSrcLines(srcfile, showfrom, 
                                            showto)), error = function(e) character())
    }
  }
  yy <- NULL
  lastshown <- 0
  srcrefs <- attr(exprs, "srcref")
  if (verbose && !is.null(srcrefs)) {
    cat("has srcrefs:\n")
    utils::str(srcrefs)
  }
  for (i in seq_len(Ne + echo)) {
    tail <- i > Ne
    if (!tail) {
      if (verbose) 
        cat("\n>>>> eval(expression_nr.", i, ")\n\t\t =================\n")
      ei <- exprs[i]
    }
    if (echo) {
      nd <- 0
      srcref <- if (tail) 
        attr(exprs, "wholeSrcref")
      else if (i <= length(srcrefs)) 
        srcrefs[[i]]
      if (!is.null(srcref)) {
        if (i == 1) 
          lastshown <- min(skip.echo, srcref[3L] - 1)
        if (lastshown < srcref[3L]) {
          srcfile <- attr(srcref, "srcfile")
          dep <- trySrcLines(srcfile, lastshown + 1, 
                             srcref[3L])
          if (length(dep)) {
            leading <- if (tail) 
              length(dep)
            else srcref[1L] - lastshown
            lastshown <- srcref[3L]
            while (length(dep) && grepl("^[[:blank:]]*$", 
                                        dep[1L])) {
              dep <- dep[-1L]
              leading <- leading - 1L
            }
            dep <- paste0(rep.int(c(prompt.echo, continue.echo), 
                                  c(leading, length(dep) - leading)), dep, 
                          collapse = "\n")
            nd <- nchar(dep, "c")
          }
          else srcref <- NULL
        }
      }
      if (is.null(srcref)) {
        if (!tail) {
          dep <- substr(paste(deparse(ei, width.cutoff = width.cutoff, 
                                      control = deparseCtrl), collapse = "\n"), 
                        12L, 1000000L)
          dep <- paste0(prompt.echo, gsub("\n", paste0("\n", 
                                                       continue.echo), dep))
          nd <- nchar(dep, "c") - 1L
        }
      }
      if (nd) {
        do.trunc <- nd > max.deparse.length
        dep <- substr(dep, 1L, if (do.trunc) 
          max.deparse.length
          else nd)
        cat(if (spaced) 
          "\n", dep, if (do.trunc) 
            paste(if (grepl(sd, dep) && grepl(oddsd, dep)) 
              " ...\" ..."
              else " ....", "[TRUNCATED] "), "\n", sep = "")
      }
    }
    if (!tail) {
      yy <- withVisible(eval(ei, envir))
      i.symbol <- mode(ei[[1L]]) == "name"
      if (!i.symbol) {
        curr.fun <- ei[[1L]][[1L]]
        if (verbose) {
          cat("curr.fun:")
          utils::str(curr.fun)
        }
      }
      if (verbose >= 2) {
        cat(".... mode(ei[[1L]])=", mode(ei[[1L]]), "; paste(curr.fun)=")
        utils::str(paste(curr.fun))
      }
      if (print.eval && yy$visible) {
        if (isS4(yy$value)) 
          methods::show(yy$value)
        else print(yy$value)
      }
      if (verbose) 
        cat(" .. after ", sQuote(deparse(ei, control = unique(c(deparseCtrl, 
                                                                "useSource")))), "\n", sep = "")
    }
  }
  invisible(yy)
}

# PMeta = "../data/Projects_metadata.csv" ## use for offline testing
PMeta = paste0("http://www.osf.io/download/","myxcv")


Projects_metadata <- read_csv(PMeta)
NO_svm = FALSE
#Timewindows = data.frame ("run it first")



# Define UI for application that draws a histogram
ui <- fluidPage(theme = "bootstrapsolar.css",
   
   # Application title
   titlePanel(title=paste0("BSeq_analyser, ",version))
   ,source ("../Softwareheader.r")
   ,     
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("Npermutation",
                     "Number of permutations to perform for the statistics:",
                     min = 1,
                     max = 600,
                     value = 1)
         , checkboxInput('RECREATEMINFILE', 'recreate the min_file even if one exists', FALSE)
         , checkboxInput('perf_SVM', 'Perform the svm analysis (takes time, not always working)', FALSE)
         , radioButtons('groupingby', 'grouping variables following which categories',
                      c('Jhuang 10 categories'='Jhuang',
                        'Berlin 18 categories'='Berlin'),
                      'Berlin')
         , shinyUI(bootstrapPage(shinyDirButton('STICK', "Data_directory", 
                          "Choose the directory containing all your HCS data (works only while running the app via Rstudio on your computer):")
         ,selectInput('Name_project', 'choose the project to analyse:',
                                      Projects_metadata$Proj_name ,
                                      'Ro_testdata')
        , textOutput("analysemessage")  
        , tags$hr()
         , textOutput("text_1")
         , a("Open the report in a new tab",target="_blank",href="report.html")
         ,actionButton("debug_go", "Go back to R to debug")
         
                          
         ))), 
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          tabPanel("multidim_results",
            "If you do not choose the time windows to incorporate in the analysis, all time windows will be used.
            "       
            ,actionButton("TWbutton", "Choose time windows")
            , tags$hr()
            ,DT::dataTableOutput('TW')  
            ,actionButton("goButton", "Perform multidimensional analysis")
                 
            , htmlOutput("includeHTML", inline = TRUE)
            #, textOutput("test")
          )
          ,tabPanel("summary reports",
                   "Note that a pdf file with all figures is also produced and saved in the Routputs folder."
                   ,actionButton("plot_data", "Plotting hourly summary data")
                   ,numericInput("obs", "plot number:", 1, min = 1, max = 20)
                   ,plotlyOutput("plot") 
                   
          )
          #,tabPanel("Interaction graphs",
                    
                    #,actionButton("plot_data", "Plotting hourly summary data")
                    #,numericInput("obs", "plot number:", 1, min = 1, max = 20)
                    #,plotlyOutput("plot") 
                    
          #)

        
        )  
        , "Use behaviour sequence (.mdr) file, or minutes/hourly summary excel exports from the Homecagescan software. Note that the light squedules should be indicated in the lab metadata files."
        
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  volumes= getVolumes(c("(C:)"))
  values <- reactiveValues()
  values$Outputshtml <- "reports/empty.html"
  values$message = "analyis not started (link will not work or show the report for a different analysis)"
  
  shinyDirChoose(input, 'STICK', roots=volumes, session = session,restrictions=system.file(package='base'))
 
   #
  fileInput <- reactive({
    filepath= (parseDirPath(volumes, input$STICK))
    filepath
  })


  
  # GObuttonbis <- observeEvent(input$goButton, {
  #   # session$sendCustomMessage(type = 'testmessage',
  #   #                          message = 'this may take some time, plese wait')
  #   values$message <- "analyis started"
  # 
  # })
  
  GObutton <- observeEvent(input$debug_go, {
    browser()
  })
  
  
  
  GObutton <- observeEvent(input$goButton, {
    # session$sendCustomMessage(type = 'testmessage',
    #                          message = 'this may take some time, plese wait')
    withProgress({
      setProgress(message = "analysis started")
      dataoutput()
      setProgress(message = "analysis done")
    
      includeHTML1()
      setProgress(message = "you should see the report soon")
      values$message <- "Click the link to see the whole report. NB the report was also saved in the analysis output folder"
      
    })
  })


  
  TWbutton <- observeEvent(input$TWbutton, {
    # session$sendCustomMessage(type = 'testmessage',
    #                          message = 'this may take some time, plese wait')
    dataoutputTW()
    
  })
  
  startmessage<- reactive({
    values$message <- "analyis started"
  })
  
  dataoutput <- reactive({
    RECREATEMINFILE <- input$RECREATEMINFILE
    NO_svm <- !input$perf_SVM
    groupingby<- input$groupingby
    Npermutation<- input$Npermutation
    STICK<- fileInput()
    Name_project <- input$Name_project
    selct_TW =  input$TW_rows_selected
   
    if (!length(selct_TW)) {selct_TW = c(1:9)}
      
    
    values$message <- "analysis finished"
    values$Outputshtml="reports/multidim_anal_variable.html"
    
    source("master_shiny.r")
    file.copy("reports/multidim_anal_variable.html", paste0("shiny__Analyse_data/www/report.html"), overwrite=TRUE,
              copy.mode = TRUE, copy.date = FALSE)
   # browser()
  })
  
  dataoutputTW <- reactive({
    RECREATEMINFILE <- input$RECREATEMINFILE
    NO_svm <- !input$perf_SVM
    groupingby<- input$groupingby
    Npermutation<- input$Npermutation
    STICK<- fileInput()
    Name_project <- input$Name_project
    selct_TW <- c(1:9)
      
      
    
    values$message <- "analyis started"
    #source <- function (x,...){source (x, local=TRUE,...)}
    source ("Rcode/get_behav_gp.r")
    values$Timewindows =Timewindows
    
    
  })
  observe(
    output$outputshtml <- renderUI({
      values$Outputshtml
    })    
  )
  

  includeHTML1<- reactive({

    paste(readLines(values$Outputshtml), collapse="\n") 
  })
  
  output$includeHTML<-renderText(includeHTML1())

  observe({
    output$text_1 <- renderText({
     values$message
    })
    onlinedata = Projects_metadata %>% 
      filter (Proj_name == input$Name_project) %>%
      select (source_data)
    analysemessage <- ifelse (onlinedata == "USB_stick",
                                     "Set directory where the software will find the data ",
                                     "This dataset is available online and can be analysed")
    output$analysemessage <- renderText({
      analysemessage
    })
     })

   

   GObuttonplot <- observeEvent(input$plot_data, {
    
      dataoutput2()
     
   })
  


dataoutput2 <- reactive({
  RECREATEMINFILE <- input$RECREATEMINFILE
  NO_svm <- !input$perf_SVM
  groupingby<- input$groupingby
  
  STICK<- fileInput()
  Name_project <- input$Name_project
  
  selct_TW =  input$TW_rows_selected
  if (!length(selct_TW)) selct_TW = c(1:9)
  values$message <- "analyis started"
  #source <- function (x,...){source (x, local=TRUE,...)}
  source("Rcode/get_behav_gp.r")
  source("Rcode/plot5_hoursummaries.r")
  values$Outputspdf=paste0(plot.path,"/14_Minutes_Behaviours_timedtolightoff.pdf")
  values$plot = pl
}) 

output$plot <- renderPlotly({
  text = paste("\n   Nothing will show here.\n",
                  "       before you push the button above")
  a= ggplot() + 
    annotate("text", x = 4, y = 25, size=8, label = text) + 
    theme_void()
  
  if (is.null(values$plot) ) return (a)
  ggplotly(values$plot[[input$obs]], originalData= FALSE) %>% layout(hovermode = "x")%>% style( hoverinfo = "none", traces = 3:4)
  
})

output$TW <- DT::renderDataTable(values$Timewindows, server = TRUE)


}



# Run the application 
shinyApp(ui = ui, server = server)

