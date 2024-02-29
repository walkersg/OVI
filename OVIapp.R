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

#tableOutput("display"),

tableOutput("differentiated"),

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
  lcl <- reactive({
  if (sum(dataWide()$control, na.rm = T) == 0) {
    lcl =  0
  }else{
    lcl = (mean(dataWide()$control, na.rm = T)-sd(dataWide()$control,na.rm = T))
    if (lcl<0)
      lcl = 0
  }
})

#upper criterion line xhat + sd for control condition
  ucl <- reactive({
  if (sum(dataWide()$control, na.rm = T) == 0) {
    ucl = 0
  } else {
  (mean(dataWide()$control,na.rm = T) + sd(dataWide()$control,na.rm = T))
  }
})

## need a loop that calculates the number of data per condition
## that are > ucl and calculated that as a proportion of length(condition)
  
  multielement <- reactive({
    
  
    
    myData() |> 
      ggplot(aes(x =as.numeric(ssn), y = as.numeric(dv), shape = condition))+
      geom_point(show.legend = T, size = 5)+
      geom_path()+
      geom_abline(slope = 0, intercept = lcl(),linetype = 3, color = 'red')+
      geom_abline(slope = 0, intercept = ucl(),linetype = 2, color = 'green')+
      theme_classic(base_size = 20)+
      theme(aspect.ratio = .5)+
      labs(title = "FA Data\n", x = "Sessions", y = "Rate", shape = "Conditions\n")
    
  })
  

  diff <- reactive({
    
    testdata<- myData() |> 
      pivot_wider(names_from = "condition",values_from = "dv")
    
    testdata<- unnest(testdata)
    
    #create empty lists
    df1dif<-c()
    df1u<-c()
    difCond<-c()
    
    #placeholder for upper criterion line
    
    #placeholder for lower criterion line
    #if (lcl()<0) {
    #  y <- 0
    #}
    
    for (i in 2:as.numeric(ncol(testdata))) {
      
      # number of data that are above the ucl placeholder (x) 
      for (counter in is.na(testdata[[i]])){
        if (counter>ucl()){
          df1dif= c(df1dif,counter)
        }
        if(counter<lcl())
          df1u = c(df1u,counter)
      }
      
      
      # converts arrays to numeric length
      df1dif=as.numeric(length(df1dif))
      df1u = as.numeric(length(df1u))
      condlength = as.numeric(length(testdata[[i]]))
      
      #checks to see if the number of data identified in the
      #above the ucl is at least 50% greater than those below
      if (abs(df1u-df1dif)/condlength>.5) {
        difCond<- rbind(difCond, paste(colnames(testdata[i])))
      }else{
        difCond<- rbind(difCond, paste(colnames(testdata[i])))
      }
    }
    colnames(difCond)<- "Differentiated Conditions"
    difCond
    
    
  })
  
  #- display wide table
  #output$display <- renderTable({
    #dataWide()
   # })
  
  #- display plot
  output$multielement<- renderPlot({
    multielement()
  })
  
  #- display differentiated conditions
  output$differentiated<-renderTable({
    diff()
  })
  }

    
shinyApp(ui, server)

