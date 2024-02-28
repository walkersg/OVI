
#In the current modified procedures, the rule for
#differentiation in a test condition was adapted
#such that 50% or more of the data points fell
#above the upper CL than fell below the lower CL.

#To calculate the percentage of data points,
#subtract the number of data points below the
#lower CL from the number of data points above
#the upper CL, divide by the total number of data
#points in that condition, and convert the result to
#a percentage.



library(tidyverse)

#load data
testdata <- read_csv("testdata.csv",na = "#N/A")



# remove data and organize in array
df = na.omit(testdata[1])[[1]]
df1<- na.omit(testdata[2])[[1]]

#create empty lists
df1dif<-c()
df1u<-c()

#placeholder for upper criterion line
x = mean(df)+sd(df)

#placeholder for lower criterion line
y = mean(df)-sd(df)

 
# number of data that are above the ucl placeholder (x) 
for (counter in df1){
  if (counter>x){
    df1dif= c(df1dif,counter)
  }
  if(counter<y)
    df1u = c(df1u,counter)
  }
}

# converts arrays to numeric length
df1dif=as.numeric(length(df1dif))
df1u = as.numeric(length(df1u))
condlength = as.numeric(length(df1))

abs(df1u-df1dif)/condlength

#checks to see if the number of data identified in the
#above the ucl is at least 50% greater than those below
if ((df1u-df1dif)/condlength>.5) {
  paste("differentiated")
}else{
  paste("undifferentiated")
}


