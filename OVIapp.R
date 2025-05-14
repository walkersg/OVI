#-------Libraries-------
library(shiny)
library(tidyverse)

# UI ----------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("OVI Tool (Visual Inspection Assistant)"), 
  
  sidebarLayout(
    sidebarPanel(
      width = 3, # Adjust sidebar width if needed
      fileInput("fa", "Upload CSV File:",
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv"),
                placeholder = "No file selected"),
      hr(), # Horizontal line for separation
      h4("Differentiated Conditions:"),
      tableOutput("differentiated_table") 
    ),
    
    mainPanel(
      width = 9, # Adjust main panel width
      h2("Visual Inspection Assistant"),
      p("This tool assists in the visual inspection of single-case data, particularly functional analyses."),
      p(strong("Reference:"), "Roane, H. S., Fisher, W. W., Kelley, M. E., Mevers, J. L., & Bouxsein, K. J. (2013). Using modified visual‐inspection criteria to interpret functional analysis outcomes. ", em("Journal of Applied Behavior Analysis, 46"), "(1), 130-146."),
      hr(),
      h4("Instructions:"),
      tags$ul(
        tags$li("Upload data in .csv format."),
        tags$li("The ", strong("first column"), " in your CSV will be treated as the 'Control' or 'Toy Play' condition."),
        tags$li("Each subsequent column will be treated as a separate test condition."),
        tags$li("Upper (green) and lower (red) criterion lines are generated from the mean of the Control condition ± one standard deviation.")
      ),
      p("For an example dataset, click the link below (ensure the file is in a 'www' subdirectory of your app):"),
      tags$a(href = 'exampledata.csv', 'Download Example Data', download = 'exampledata.csv'), # Assumes 'exampledata.csv' is in 'www/'
      hr(),
      plotOutput("multielement_plot"), 
      hr(),
      p(strong("Created by:"), "Seth Walker, PhD, BCBA-D. Contact: sethgregorywalker@gmail.com"),
      tags$a(href = "https://www.sethgregorywalker.com", "www.sethgregorywalker.com", target = "_blank")
    )
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  #--- Reactive: Read and process uploaded CSV ---
  data_wide <- reactive({
    req(input$fa) # Requires a file to be uploaded
    
    inFile <- input$fa
    tryCatch({
      df <- read_csv(inFile$datapath, na = c("#N/A", "NA", ""), show_col_types = FALSE)
      if (ncol(df) < 1) {
        stop("CSV file must contain at least one column.")
      }
      return(df)
    }, error = function(e) {
      showNotification(paste("Error reading CSV:", e$message), type = "error", duration = 10)
      return(NULL)
    })
  })
  
  #--- Reactive: Transform data to long format for ggplot2 ---
  data_long <- reactive({
    req(data_wide()) 
    
    df_wide <- data_wide()
    
    # Assuming the first column is 'Control' and its name might vary.
    # We use its position for calculations and preserve its name for plotting.
    # If there is only one column, it's the control.
    control_col_name <- names(df_wide)[1]
    
    df_long <- df_wide %>%
      mutate(session_id = row_number()) %>% # Add a session identifier
      pivot_longer(cols = -session_id,
                   names_to = 'condition',
                   values_to = 'dv',
                   values_drop_na = TRUE) %>%
      mutate(
        dv = as.numeric(dv),
        # Ensure condition factor levels match original column order
        condition = factor(condition, levels = names(df_wide))
      )
    
    return(df_long)
  })
  
  #--- Reactive: Calculate statistics for the control condition ---
  control_stats <- reactive({
    req(data_wide())
    # Use the first column as the control condition
    control_data <- data_wide()[[1]] %>% na.omit()
    
    if (length(control_data) == 0) {
      return(list(mean = NA_real_, sd = NA_real_, lcl = NA_real_, ucl = NA_real_))
    }
    
    control_mean <- mean(control_data, na.rm = TRUE)
    control_sd <- if (length(control_data) < 2) 0 else sd(control_data, na.rm = TRUE)
    
    lcl_val <- control_mean - control_sd
    ucl_val <- control_mean + control_sd
    
    list(
      mean = control_mean,
      sd = control_sd,
      lcl = max(0, lcl_val, na.rm = TRUE), # LCL cannot be less than 0
      ucl = ucl_val
    )
  })
  
  #--- Reactive: Generate the multielement plot ---
  plot_object <- reactive({ # Renamed from multielement to avoid confusion
    req(data_long(), control_stats())
    
    df_long <- data_long()
    stats <- control_stats()
    
    # Validate required data for plotting
    validate(
      need(!is.na(stats$lcl) && !is.na(stats$ucl), "Cannot calculate LCL/UCL. Check control data.")
    )
    
    gg <- ggplot(df_long, aes(x = session_id, y = dv, shape = condition, color = condition)) +
      geom_line(aes(group = condition), linewidth = 0.8) + # Connect points within each condition
      geom_point(size = 4, fill = "white", stroke = 1.5) + # Make points stand out
      geom_hline(yintercept = stats$lcl, linetype = "dashed", color = "red", linewidth = 1) +
      geom_hline(yintercept = stats$ucl, linetype = "dotted", color = "green", linewidth = 1) +
      scale_shape_manual(values = 1:n_distinct(df_long$condition)) + # Ensure enough shapes
      labs(
        title = "Functional Analysis Data",
        x = "Session Number",
        y = "Dependent Variable (Rate/Percentage)",
        shape = "Condition",
        color = "Condition"
      ) +
      theme_classic(base_size = 15) +
      theme(
        aspect.ratio = 0.6,
        legend.position = "top",
        plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.title = element_text(face = "bold"),
        legend.title = element_text(face = "bold")
      )
    
    return(gg)
  })
  
  #--- Reactive: Calculate differentiated conditions ---
  differentiated_summary <- reactive({ # Renamed from diff
    req(data_long(), control_stats())
    
    df_long <- data_long()
    stats <- control_stats()
    
    validate(
      need(!is.na(stats$lcl) && !is.na(stats$ucl), "Cannot calculate LCL/UCL for differentiation. Check control data.")
    )
    
    # Get the name of the control condition (first column) to exclude it from analysis
    control_condition_name <- levels(df_long$condition)[1]
    
    summary_table <- df_long %>%
      filter(condition != control_condition_name) %>% # Only analyze test conditions
      group_by(condition) %>%
      summarise(
        total_points = n(),
        points_above_ucl = sum(dv > stats$ucl, na.rm = TRUE),
        points_at_or_below_lcl = sum(dv <= stats$lcl, na.rm = TRUE), # Based on your original logic "counter <= lcl()"
        .groups = 'drop'
      ) %>%
      mutate(
        # Your differentiation criterion: (count_above_UCL - count_at_or_below_LCL) / total_points > 0.5
        # Ensure total_points > 0 to avoid division by zero
        is_differentiated_value = if_else(
          total_points > 0,
          (points_above_ucl - points_at_or_below_lcl) / total_points > 0.5,
          FALSE # Default for conditions with no data points
        ),
        `Differentiated?` = if_else(is_differentiated_value, "YES", "NO")
      ) %>%
      select(Condition = condition, `Differentiated?`)
    
    # If no test conditions exist (e.g., only control data uploaded)
    if (nrow(summary_table) == 0 && n_distinct(df_long$condition) <=1 && names(data_wide())[1] == control_condition_name) {
      return(tibble(Condition = "No test conditions found.", `Differentiated?` = "-"))
    }
    
    return(summary_table)
  })
  
  #--- Render Outputs ---
  output$multielement_plot <- renderPlot({
    validate(need(data_wide(), "Please upload a CSV file to generate the plot."))
    plot_object()
  })
  
  output$differentiated_table <- renderTable({
    validate(need(data_wide(), "Please upload a CSV file for differentiation analysis."))
    differentiated_summary()
  })
  
}

shinyApp(ui, server)