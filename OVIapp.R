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

#tableOutput("display1"),

plotOutput("multielement")

)



# server ------------------------------------------------------------------


server <- function(input, output, session) {
  
#- csv to table format
  dataWide <- reactive({
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

#lower criterion line xhat - sd for control condition
## need to embed an if-else for control == 0
lcl <- reactive({
  (mean(dataWide()$control,na.rm = T)-sd(dataWide()$control,na.rm = T))
})

#upper criterion line xhat + sd for control condition
## need to embed an if-else for control == 0
ucl <- reactive({
  (mean(dataWide()$control,na.rm = T)+sd(dataWide()$control,na.rm = T))
})
  
  multielement <- reactive({
    
  
    
    myData() |> 
      ggplot(aes(x =as.numeric(ssn), y = as.numeric(dv), shape = condition))+
      geom_point(show.legend = T, size = 5)+
      geom_path()+
      geom_abline(slope = 0, intercept = lcl(),linetype = 3, color = 'red')+
      geom_abline(slope = 0, intercept = ucl(),linetype = 2, color = 'green')+
      theme_classic(base_size = 20)+
      theme(aspect.ratio = .5)+
      ylab("Rate")+
      xlab("Sessions")
    
  })
  
  #- display wide table
  output$display <- renderTable({
    dataWide()
    })
  
  #- display narrow table
 #output$display1 <- renderTable({
 #control()
#  })
  
  #- display plot
  output$multielement<- renderPlot({
    multielement()
  })
  
  }

    
shinyApp(ui, server)

