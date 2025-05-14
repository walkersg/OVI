# OVI Tool (Visual Inspection Assistant) - R Shiny App

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [How to Use](#how-to-use)
- [Input Data Format](#input-data-format)
- [Output](#output)
- [Reference](#reference)
- [Example Data](#example-data)
- [Running the App Locally](#running-the-app-locally)
- [Dependencies](#dependencies)
- [Author](#author)

## Overview
The OVI Tool (Visual Inspection Assistant) is an R Shiny application designed to assist in the visual inspection of single-case data, with a particular focus on functional analyses. It allows users to upload their data in CSV format, visualizes the data in a multielement plot, and provides an automated assessment of differentiated conditions based on established criteria.

The visual inspection criteria are based on the methodology described by Roane et al. (2013).

## Features
- **CSV Data Upload:** Easily upload your single-case data in a `.csv` file.
- **Automated Plot Generation:** Creates a multielement-style line graph.
- **Control Condition Focus:** The first column of the uploaded data is automatically treated as the 'Control' or 'Toy Play' condition.
- **Criterion Lines:** Upper (green) and lower (red) criterion lines are generated based on the mean of the Control condition ± one standard deviation.
- **Differentiated Conditions Table:** Displays a summary table indicating which test conditions are differentiated from the control condition.
- **User-Friendly Interface:** Simple layout for ease of use.
- **Downloadable Example Data:** Includes a sample dataset to demonstrate the required format and functionality.

## How to Use
1.  **Prepare your data:** Ensure your data is in a CSV file format (see [Input Data Format](#input-data-format) below).
2.  **Upload your CSV file:** Use the "Upload CSV File" button in the sidebar to select and upload your data.
3.  **View the Plot:** Once the file is uploaded, a multielement graph will be generated in the main panel, displaying your data with the calculated criterion lines.
4.  **Check Differentiated Conditions:** A table in the sidebar will show each test condition and whether it is considered "Differentiated" (YES/NO) based on the specified criteria.

## Input Data Format
-   The data must be in a **CSV (Comma Separated Values) file**.
-   The **first column** will always be treated as the 'Control' or 'Toy Play' condition. The mean and standard deviation of this column are used to calculate the criterion lines.
-   Each **subsequent column** will be treated as a separate test condition (e.g., Attention, Demand, Alone).
-   Each **row** typically represents a session or observation point.
-   Values in the cells should be numeric, representing the dependent variable (e.g., rate of behavior, percentage of intervals).
-   Missing values can be represented as `NA`, `#N/A`, or an empty cell.

**Example CSV Structure:**
```csv
Control,ConditionA,ConditionB,ConditionC
10,15,12,11
8,18,10,13
12,20,14,9
NA,22,11,10
9,17,NA,12
```
## Output
The application provides two main outputs:

1.  **Multielement Plot:**
    * A line graph displaying the dependent variable across sessions for each condition.
    * Each condition is represented by a different color and shape.
    * A red dashed line indicates the Lower Criterion Line (LCL): Mean of Control - 1 SD (floored at 0).
    * A green dotted line indicates the Upper Criterion Line (UCL): Mean of Control + 1 SD.
2.  **Differentiated Conditions Table:**
    * A table shown in the sidebar.
    * Lists each test condition (all conditions except the first/control column).
    * Indicates whether each condition is "Differentiated?" (YES/NO).
    * Differentiation Criterion: A test condition is considered differentiated if the proportion `(points_above_UCL - points_at_or_below_LCL) / total_points_in_condition` is greater than 0.5.

## Reference
This tool and its visual inspection criteria are based on:

Roane, H. S., Fisher, W. W., Kelley, M. E., Mevers, J. L., & Bouxsein, K. J. (2013). Using modified visual‐inspection criteria to interpret functional analysis outcomes. *Journal of Applied Behavior Analysis, 46*(1), 130-146.

## Example Data
An example CSV file (`exampledata.csv`) is provided to demonstrate the expected data format.

-   You can download it using the "Download Example Data" link within the app.
-   **Important:** For the download link to work when running the app locally, the `exampledata.csv` file must be placed in a subdirectory named `www` within the same directory as your `app.R` (or `ui.R` and `server.R`) file.

Structure of the `www` directory:
```
your_app_directory/
├── app.R
└── www/
└── exampledata.csv
```
## Running the App Locally
To run this Shiny application on your local machine:

1.  Ensure R and RStudio are installed.
2.  Install necessary packages:
    ```R
    install.packages(c("shiny", "tidyverse"))
    ```
3.  Save the code: Save the provided R script as an `app.R` file (or as `ui.R` and `server.R` files in the same directory).
4.  Create `www` subdirectory (Optional but recommended for example data): If you want to use the example data download link, create a folder named `www` in the same directory as `app.R` and place the `exampledata.csv` file inside it.
5.  Run the app:
    * Open the `app.R` file in RStudio.
    * Click the "Run App" button in RStudio.
    * Alternatively, you can run it from the R console by navigating to the app's directory and using the command:
        ```R
        shiny::runApp()
        ```

## Dependencies
This application requires the following R packages:

-   `shiny`: For building the interactive web application.
-   `tidyverse`: For data manipulation (specifically `dplyr` and `tidyr` for `read_csv`, `pivot_longer`, `mutate`, etc.) and plotting (`ggplot2`).

## Author
**Seth Walker, PhD, BCBA-D**

-   Email: sethgregorywalker@gmail.com
-   Website: [www.sethgregorywalker.com](http://www.sethgregorywalker.com)
