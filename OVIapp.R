#outline
#Title
#Data upload
#Output table
##Multielement Graph
##LCL, UCL, and projection


#-------Libraries
library(shiny)
library(tidyverse)
library(tidymodels)

#

ui <- fluidPage(
# UI ----------------------------------------------------------------------
  
  titlePanel("OVI Tool"),
  
  
  fileInput("fa","Upload CSV", accept = ".csv"),

  
  #textInput("control", "Input the name of the control condition", value = "case sensitive"),

tableOutput("display"),

tableOutput("display1")
)



# server ------------------------------------------------------------------


server <- function(input, output, session) {
  
#- csv to table format
  data <- reactive({
    inFile <- input$fa
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE)
    data
  })
  #- csv to long format - needed for ggplot2
  myData <- reactive({
    inFile <- input$fa
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE)
    data <- data |> 
      pivot_longer(cols = everything(),
                   names_to = 'condition',
                   values_to = 'dv',
                   values_drop_na = T)
  })
  
  #- display wide table
  output$display <- renderTable({
    data()
    })
  
  #- display narrow table
  output$display1 <- renderTable({
    myData()
  })
  
  }

    
  

shinyApp(ui, server)

