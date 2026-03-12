library(shiny)
library(bslib)
library(dplyr)
library(plotly)

data <- read.csv(
  "https://raw.githubusercontent.com/UBC-MDS/DSCI-532_2026_30_social-media-addiction/refs/heads/main/data/raw/Students-Social-Media-Addiction.csv"
)


#UI
ui <- page_fillable(
  title = "Social Media Addiction Dashboard",
  h1("Social Media Addiction Dashboard"),
  
  #input
  layout_sidebar(
    sidebar= sidebar(
      radioButtons(
        inputId = "f_gender",
        label = "Gender",
        choices = c("All", "Male", "Female"),
        selected = "All"
      ),
      
      sliderInput(
        inputId = "f_age",
        label = "Age",
        min = min(data$Age),
        max = max(data$Age),
        value = c(min(data$Age), max(data$Age))
      ),
      
      selectInput(
        inputId = "f_level", 
        label = "Academic Level", 
        choices = c("All", "Undergraduate", "Graduate"), 
        selected = "All",
        multiple = FALSE
      )
    ),
    
    #output
    layout_columns(
      value_box(
        title = "Total Students",
        value = textOutput("tile_students")
      ),
      value_box(
        title = "Average Daily Usage",
        value = textOutput("tile_usage")
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Impact on Academic Performance"),
        plotlyOutput("plot_AAP"),
        full_screen = TRUE
      ),
      
      card(
        card_header("Academic Level Distribution by Gender"),
        plotlyOutput("plot_academiclvldist"),
        full_screen = TRUE
      ),
      col_widths = c(6, 6)
    )
  )
)


#Server
server <- function(input, output, session) {
  filtered_df <- reactive({
    df <- data |> 
      filter(Academic_Level %in% c("Undergraduate", "Graduate"))
    
    if (input$f_gender != "All"){
      df <- df |> 
        filter(Gender == input$f_gender)
    }
    
    df <- df |> 
      filter(Age >= input$f_age[1], Age <= input$f_age[2])
    
    if (input$f_level != "All"){
      df <- df |> 
        filter(Academic_Level == input$f_level)
    }
    df
  })
  
  output$tile_students <- renderText({nrow(filtered_df())
  })
  
  output$tile_usage <- renderText({
    d <- filtered_df()
    if (nrow(d) == 0) "—" else sprintf("%.1fh", mean(d$Avg_Daily_Usage_Hours, na.rm = TRUE))
  })
  
  output$plot_AAP <- renderPlotly({
    df1 <- filtered_df()
    
    percent <- df1 |>
      count(Affects_Academic_Performance) |>
      rename(Count = n) |>
      mutate(
        Percentage = round(Count / sum(Count) * 100, 1),
        label = paste0(Percentage, "%"))
    
    plot_ly(
      percent,
      x = ~Percentage,
      y = ~Affects_Academic_Performance,
      type = "bar",
      orientation = "h",
      color = ~Affects_Academic_Performance,
      colors = c("Yes" = "#c0392b", "No" = "#1e3a6e"),
      text = ~label,
      textposition = "outside",
      hovertemplate = ~paste0(
        "Affects Academic Performance: ", Affects_Academic_Performance, "<br>",
        "Number of Students: ", Count, "<br>",
        "Percentage: ", Percentage, "%<extra></extra>")
    ) |>
      layout(
        xaxis = list(title = "Percentage of Students", range = c(0, 110)),
        yaxis = list(title = "Impact on Academic Performance"),
        showlegend = FALSE)
  })
  
  output$plot_academiclvldist <- renderPlotly({
    df2 <- filtered_df()
    
    grouped <- df2 |>
      count(Academic_Level, Gender) |>
      mutate(Academic_Level = factor(Academic_Level, levels = c("Undergraduate", "Graduate")))
    
    plot_ly(
      grouped,
      x = ~Academic_Level,
      y = ~n,
      color = ~Gender,
      colors = c("Male" = "#1e3a6e", "Female" = "#5ba4cf"),
      type = "bar",
      hovertemplate = paste(
        "<b>%{x}</b><br>",
        "Gender: %{fullData.name}<br>",
        "Count: %{y}<extra></extra>"
      )
    ) |>
      layout(
        barmode = "stack",
        xaxis = list(title = "Academic Level"),
        yaxis = list(title = "Number of Students")
      )
  })
}
shinyApp(ui, server)