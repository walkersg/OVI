Output
The application provides two main outputs:

Multielement Plot:

A line graph displaying the dependent variable across sessions for each condition.
Each condition is represented by a different color and shape.
A red dashed line indicates the Lower Criterion Line (LCL): Mean of Control - 1 SD (floored at 0).
A green dotted line indicates the Upper Criterion Line (UCL): Mean of Control + 1 SD.
Differentiated Conditions Table:

A table shown in the sidebar.
Lists each test condition (all conditions except the first/control column).
Indicates whether each condition is "Differentiated?" (YES/NO).
Differentiation Criterion: A test condition is considered differentiated if the proportion (points_above_UCL - points_at_or_below_LCL) / total_points_in_condition is greater than 0.5.
Reference
This tool and its visual inspection criteria are based on:

Roane, H. S., Fisher, W. W., Kelley, M. E., Mevers, J. L., & Bouxsein, K. J. (2013). Using modified visual‐inspection criteria to interpret functional analysis outcomes. Journal of Applied Behavior Analysis, 46(1), 130-146.

Example Data
An example CSV file (exampledata.csv) is provided to demonstrate the expected data format.

You can download it using the "Download Example Data" link within the app.
Important: For the download link to work when running the app locally, the exampledata.csv file must be placed in a subdirectory named www within the same directory as your app.R (or ui.R and server.R) file.
Structure of the www directory:

your_app_directory/
├── app.R
└── www/
    └── exampledata.csv
Running the App Locally
To run this Shiny application on your local machine:

Ensure R and RStudio are installed.
Install necessary packages:
R

install.packages(c("shiny", "tidyverse"))
Save the code: Save the provided R script as an app.R file (or as ui.R and server.R files in the same directory).
Create www subdirectory (Optional but recommended for example data): If you want to use the example data download link, create a folder named www in the same directory as app.R and place the exampledata.csv file inside it.
Run the app:
Open the app.R file in RStudio.
Click the "Run App" button in RStudio.
Alternatively, you can run it from the R console by navigating to the app's directory and using the command:
R

shiny::runApp()
Dependencies
This application requires the following R packages:

shiny: For building the interactive web application.
tidyverse: For data manipulation (specifically dplyr and tidyr for read_csv, pivot_longer, mutate, etc.) and plotting (ggplot2).
Author
Seth Walker, PhD, BCBA-D

Email: sethgregorywalker@gmail.com
Website: www.sethgregorywalker.com
