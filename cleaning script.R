library(tidyverse)

#path to test functional analysis data
Test_FA_data <- read_csv(FA_path, na = "#N/A")

#- Convert to a format amenable to multielement graphing 2 x n with NA values removed

#heads<- colnames(data)


df <- Test_FA_data |> 
  pivot_longer(cols = everything(),
               names_to = 'condition',
               values_to = 'dv',
               values_drop_na = T) 


#- assign session number to data frame now 3 x n

df$session<- seq.int(nrow(df))

#- reorder for sanity
df<- df |> 
  select(session, dv, condition)

#- plot data
plotobj <- df |> 
  ggplot(aes(x = session, y = dv, shape = condition))+
  geom_point(show.legend = T)+
  geom_path()+
  theme_classic()+
  theme(aspect.ratio = .75)

plotobj

