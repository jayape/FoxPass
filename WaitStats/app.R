library(shiny)
library(RODBC)
library(dplyr)
library(dygraphs)
library(zoo)
library(xts)

ui <- fluidPage(
  titlePanel("Wait Stats Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("server", label = h3("Select Server"), 
                  choices = list("Server 1" = "DCICHISQL1", 
                                 "Server 2" = "DCICHISQL2", 
                                 "Server 3" = "DCICORSQL3", 
                                 "Server 4" = "DCICORSQL4", 
                                 "Server 5" = "DCICORSQL8"), 
                  selected = "DCICHISQL1"),
      radioButtons("wt", label = h3("Select Wait Type"),
                   c("ASYNC_NETWORK_IO" = "ASYNC_NETWORK_IO",
                     "LATCH_EX" = "LATCH_EX",
                     "PAGEIOLATCH_EX" = "PAGEIOLATCH_EX")),
      dateRangeInput("dates", 
                     label = h3("Select Date Range"), 
                     start = Sys.Date() - 30,
                     end = Sys.Date())
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Data", DT::dataTableOutput("table")),
          tabPanel("Graph", dygraphOutput("graph"))
      )
    )
  )
)

server <- function(input, output) {
  myConn <- odbcDriverConnect("driver={SQL Server};
                               server=(local);
                               database=DemoDB;
                               Trusted_Connection=yes")
  ws <- sqlFetch(myConn, "MonthlyWaitStats")
  close(myConn)
  
  data <- reactive ({
    m <- ws %>%
        filter(ServerName == input$server, 
               wait_type == input$wt, 
               dt >= as.POSIXct(input$dates[1]) & dt <= as.POSIXct(input$dates[2])) %>%
        group_by(wait_type) %>%
        mutate(waiting_tasks_count_diff = waiting_tasks_count - lag(waiting_tasks_count, default = waiting_tasks_count[1])) %>%
        mutate(wait_time_ms_diff = wait_time_ms - lag(wait_time_ms, default = wait_time_ms[1])) %>%
        mutate(signal_wait_time_ms_diff = signal_wait_time_ms - lag(signal_wait_time_ms, default = signal_wait_time_ms[1]))
      
    return(m[, c(1:3, 8:10)])
  })
    
  output$table <- DT::renderDataTable({
    data()
  })
  
  output$graph <- renderDygraph({
    myPlot <- xts(data(), as.POSIXct(data()$dt,  format="(%y/%m/%d %H:%M:%S)"))
    dygraph(myPlot) %>% dyRangeSelector()
  })

}

shinyApp(ui, server)
