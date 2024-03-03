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
  
sidebarLayout(
    
  #data upload relegated to sidepanel
    sidebarPanel(fileInput("fa","Upload CSV", accept = ".csv"),
                 tableOutput("differentiated")),
    
    #info about project and how to
    mainPanel(
      h2("Visual Inspection Assistant"),
      p("Based on: Roane, H. S., Fisher, W. W., Kelley, M. E., Mevers, J. L., & Bouxsein, 
        K. J. (2013). Using modified visual‐inspection criteria to interpret functional
        analysis outcomes. Journal of Applied Behavior Analysis, 46(1), 130-146."),
      p("How To: Upload data in .csv form with the 
        control or toy play condition listed first. Each subsequent column
        will be treated as a test condition. Upper (green) and lower (red) criterion lines are generated using 
        the mean of the control condition plus and minus one standard 
        deviation respectively."),
      tags$a(href="www/testdata.png", "Example Data", download="exampledata.png"),
      p("Created by: Seth Walker, PhD, BCBA-D. Contact: sethgregorywalker@gmail.com"),
      tags$a(href="https://www.sethgregorywalker.com", "www.sethgregorywalker.com"),
      
      #download link for sample data
      
      #multielement plot of uploaded data
      plotOutput("multielement"),
              
      tags$style(type="text/css",
         ".shiny-output-error { visibility: hidden; }",
         ".shiny-output-error:before { visibility: hidden; }"))
    ),
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
    data <- dataWide() |>
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
  if (mean(dataWide()$control, na.rm = T)-sd(dataWide()$control,na.rm = T) < 0 ) {
    lcl =  0
  }else{
    lcl = (mean(dataWide()$control, na.rm = T)-sd(dataWide()$control,na.rm = T))
  }
})

#upper criterion line xhat + sd for control condition
  ucl <- reactive({
  if (sum(dataWide()$control, na.rm = T) == 0) {
    ucl = 0
  } else {
  (mean(dataWide()$control, na.rm = T) + sd(dataWide()$control,na.rm = T))
  }
})

#create multielement graph with upper and lower criterion lines
  
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
 
  #calculate the an index of the number of data above the UCL and 
  #below the LCL NOT in between 

  diff <- reactive({
    testdata<- myData()
  
    ## remove session column  
    testdata<- testdata |> select(2:ncol(testdata))
    
    ##pivot back to wide without NA vals
    testdata<- testdata |> 
      pivot_wider(names_from = "condition",values_from = "dv")
    
    testdata<- unnest(testdata)
    
    testdata<- testdata |> mutate_at(1:ncol(testdata), as.numeric)
    
    testdata<- testdata |> select(2:ncol(testdata))
    testdata<- as.data.frame(testdata)
    
    #create empty lists
    df1dif<-c()
    df1u<-c()
    difCond<-c()
    
    for (i in 1:length(testdata)){
      condlength = as.numeric(length(testdata[,i]))
      # number of data that are above the ucl placeholder (x) 
      for (counter in testdata[,i]){
        if (counter>ucl()){
          df1dif= c(df1dif,counter)
        }
        if(counter<=lcl())
          df1u = c(df1u,counter)
      }
      # converts arrays to numeric length
      df1dif=as.numeric(length(df1dif))
      df1u = as.numeric(length(df1u))
      
      #checks to see if the number of data identified in the
      #above the ucl is at least 50% greater than those below
      if ((df1dif-df1u)/condlength>.5) {
        difCond<- rbind(difCond,paste(colnames(testdata)[i],"-","YES"))
      }else{
        difCond<- rbind(difCond,paste(colnames(testdata)[i],"-","NO"))
      }
    }
    difCond<-as.data.frame(difCond)
    colnames(difCond) = "Differentiated Conditions"
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

