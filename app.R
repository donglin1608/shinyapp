# Install necessary libraries (if not installed)
if(!require(shiny)) install.packages("shiny")
if(!require(leaflet)) install.packages("leaflet")
if(!require(readxl)) install.packages("readxl")
if(!require(ggmap)) install.packages("ggmap")
if(!require(dplyr)) install.packages("dplyr")

# Load the libraries
library(shiny)
library(leaflet)
library(readxl)
library(ggmap)
library(dplyr)

# Register Google API key (replace with your actual API key)
register_google(key = "AIzaSyCFkCZbfL_zFHU7iPP3_29-nhjt9JQqijA")

# Define UI for the Shiny app
ui <- fluidPage(
  titlePanel("Tulsa Restaurants - Map with Interactive Ratings"),
  
  sidebarLayout(
    sidebarPanel(
      p("Summary of Interaction Features:"),
      tags$ul(
        tags$li("Click on a marker: Opens a popup with the restaurant’s name, address, and rating."),
        tags$li("Zoom in/out: Use +/- buttons or your mouse wheel."),
        tags$li("Pan the map: Click and drag or use the arrow keys."),
        tags$li("Color legend: In the bottom-right, showing the rating scale."),
        tags$li("Explore restaurant distribution: Look for clusters of markers in different parts of Tulsa.")
      )
    ),
    
    mainPanel(
      leafletOutput("map")  # Output for the map
    )
  )
)

# Define server logic for the Shiny app
server <- function(input, output) {
  # Load the dataset (use relative path)
  df <- read_excel("Tulsa Restaurant Data.xlsx")
  
  # Geocode the addresses
  df_geocoded <- df %>%
    rowwise() %>%
    mutate(geocode_result = geocode(Address)) %>%
    mutate(lat = geocode_result$lat, lon = geocode_result$lon) %>%
    filter(!is.na(lat), !is.na(lon))  # Remove rows with missing geocodes
  
  # Create a reactive output for the map
  output$map <- renderLeaflet({
    # Create a color palette based on the ratings (Red for low, Green for high)
    pal <- colorNumeric(palette = c("red", "yellow", "green"), domain = df_geocoded$Rating)
    
    # Plot the restaurants on a leaflet map with interactivity
    leaflet(data = df_geocoded) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~lon, lat = ~lat, 
        color = ~pal(Rating), 
        radius = ~Rating * 1.5, # Larger markers for higher ratings
        stroke = FALSE, 
        fillOpacity = 0.7,
        popup = ~paste("<strong>", Name, "</strong><br/>",
                       "Address: ", Address, "<br/>",
                       "Rating: ", Rating)
      ) %>%
      addLegend("bottomright", 
                pal = pal, 
                values = df_geocoded$Rating,
                title = "Restaurant Rating",
                opacity = 1) %>%
      setView(lng = mean(df_geocoded$lon), lat = mean(df_geocoded$lat), zoom = 12) # Center and zoom
  })
}

# Run the application
shinyApp(ui = ui, server = server)

