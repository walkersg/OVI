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

tableOutput("display1"),

plotOutput("multielement")
)



# server ------------------------------------------------------------------


server <- function(input, output, session) {
  
#- csv to table format
  data <- reactive({
    inFile <- input$fa
    if (is.null(inFile)) return(NULL)
    data <- read_csv(inFile$datapath, na = "#N/A")
    data
    
  })
  #- csv to long format - needed for ggplot2
  myData <- reactive({
    inFile <- input$fa
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE, na.strings = "#N/A")
    data <- data |> 
      pivot_longer(cols = everything(),
                   names_to = 'condition',
                   values_to = 'dv',
                   values_drop_na = T)
    
    data<- as.matrix(data)
    ssn<- seq.int(nrow(data))
    ssn<- as.integer(ssn)
    data <- cbind(data,ssn)
    data<-as_data_frame(data)
    data<-data[, c(3,2,1)]
  })
  
  multielement <- reactive({
    myData() |> 
      ggplot(aes(x = ssn, y = dv, shape = condition))+
      geom_point(show.legend = T)+
      geom_path()+
      theme_classic()+
      theme(aspect.ratio = .5)
    
  })
  
  #- display wide table
  output$display <- renderTable({
    data()
    })
  
  #- display narrow table
  output$display1 <- renderTable({
    myData()
  })
  
  #- display plot
  output$multielement<- renderPlot({
    multielement()
  })
  
  }

    
  

shinyApp(ui, server)

