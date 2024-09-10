# Install the shiny package if you don't have it
if (!require(shiny)) install.packages("shiny")

# Load the shiny library
library(shiny)

# Define UI for the application
ui <- fluidPage(
  titlePanel("Hello Shiny!"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins", 
                  "Number of bins:", 
                  min = 1, 
                  max = 50, 
                  value = 30)
    ),
    
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

# Define server logic to plot histogram
server <- function(input, output) {
  output$distPlot <- renderPlot({
    x <- faithful$eruptions
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

