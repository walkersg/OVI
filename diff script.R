
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


testdata <- read_csv("testdata2.csv", na = "#N/A")

#convert long to drop NA
testdata<-testdata |> 
  pivot_longer(cols = everything(),
               names_to = 'condition',
               values_to = 'dv',
               values_drop_na = T)
testdata<-testdata |> 
  pivot_wider(names_from = "condition",values_from = "dv")

testdata<- unnest(testdata)

#create empty lists
df1dif<-c()
df1u<-c()
difCond<-c()

#placeholder for upper criterion line
x = mean(testdata[[1]],na.rm = T) + sd(testdata[[1]],na.rm = T)

#placeholder for lower criterion line
y = mean(testdata[[1]],na.rm = T) - sd(testdata[[1]],na.rm = T)
if (y<0) {
  y=0
}

for (i in 2:as.numeric(ncol(testdata))) {
  
# number of data that are above the ucl placeholder (x) 
for (counter in testdata[[i]]){
  if (counter>x){
    df1dif= c(df1dif,counter)
  }
  if(counter<y)
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
