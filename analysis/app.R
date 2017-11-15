#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
require (shinyFiles)

#setwd("analysis")
##multidimensional analysis:
library (randomForest)
library (ica)
library (e1071) #svm
require(Hmisc)   #binomial confidence 

library(osfr) ##access to osf

#normal libraries:
library (tidyverse)
library (stringr)
#for plotting
library(gridExtra)
library(RGraphics)
source ("Rcode/functions.r")



PMeta = osfr::path_file("myxcv")
Projects_metadata <- read_csv(PMeta)
# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Analyse your home cage monitoring data. https://github.com/jcolomb/HCS_analysis"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("Npermutation",
                     "Number of permutations to perform for the statistics:",
                     min = 1,
                     max = 1000,
                     value = 240)
         , checkboxInput('RECREATEMINFILE', 'recreate the min_file even if one exists', FALSE)
         , radioButtons('groupingby', 'grouping variables following which categories',
                      c('Jhuang 10 categories'='MITsoft',
                        'Berlin 18 categories'='AOCF'),
                      'MITsoft')
         , shinyDirButton("STICK", "Data_directory", 
                          "Choose the directory containing all your HCS data (works only while running the app via Rstudio on your computer):")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        selectInput('groupingby', 'choose the project to analyse:',
                        Projects_metadata$Proj_name ,
                        'test_online')
        
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  values <- reactiveValues()
  values$inventory <- NULL
  
  
  

   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

