library(shiny)
library(plotly)
library(data.table)
library(htmlwidgets)
library(stringi)

source('Configuration.R')

highlightValues <- function(values)
{
  js <- stri_replace_all(jsHighLightPoint, values$x, fixed="{x}")
  js <- stri_replace_all(js, values$y, fixed="{y}")
  js <- stri_replace_all(js, values$plot, fixed="{plotNo}")
  return(js)
}

eventClick <- function(session, values) 
{
  shinyjs::runjs(highlightValues(values$highlightedValues))
  showModal(modalDialog(
    numbersToMessage(values$highlightedValues),
    reactingPlot(values$highlightedValues)
  ), session=session)
}

numbersToMessage <- function(numbers)
{
  if (length(numbers) < 4)
  {
    return("No points were selected")    
  }
  else
  {
    return(paste("You clicked on a point with the following coordinates: x: ", numbers[3], ", y: ", numbers[4], sep=""))
  }
}

definedPlot <- function(values, source)
{
  print('plotting defined plot')
  renderPlotly({
    plot_ly(type='scatter', x=values$x, y=values$y, source=source, mode='markers') %>% 
      add_trace(type='scatter', x=c(0), y=c(0), mode='markers', name="", visible=FALSE) %>% 
      layout(showlegend=FALSE)
  })
}

matchingFile <- function(filename)
{
  return(stri_replace_all(filename, "more", fixed="Simple"))
}

eventDropDown <- function(input, output, session, values)
{
  print('dropDown event')
  values$points1 <- fread(paste(appDir, input$dropDownFile, sep="/"))
  values$points2 <- fread(paste(appDir, matchingFile(input$dropDownFile), sep="/"))
  print(paste(appDir, matchingFile(input$dropDownFile), sep="/"))
  values$highlightedValues = NULL
  output$plot0 <- definedPlot(values$points1, "plot0")
  output$plot1 <- definedPlot(values$points2, "plot1")
}

mockupValues <- function(x)
{
  repeats = length(x)
  values = c()
  index = 0
  while (repeats > 0)
  {
    index = index + 1
    repeats = repeats - 1
    by_ <- x[index]/abs(x[index]) * 0.01
    valueRange <- seq(from=x[index] * 0.8, to=x[index] * 1.2, by=by_)
    values <- c(values, sample(valueRange, size=30, replace=TRUE))
  }
  return(values)
}

reactingPlot <- function(values)
{
  if (is.null(values) == TRUE || is.null(values$x) == TRUE)
  {
    print('nothing selected or clicked')
    x <- c()
    y <- c()
  }
  else
  {
    x <- mockupValues(values$x)
    y <- mockupValues(values$y)
  }
  renderPlotly({
    plot_ly(type='scatter', x=x, y=y, mode='markers') %>% 
      layout(xaxis=list(range=c(-10, 10)),
      yaxis=list(range=c(-10, 10)))
  })
}

shinyServer(function(input, output, session) {
  values <- reactiveValues()
  values$highlightedValues = list(x="", y="")
  output$plot <- definedPlot(values$points)
  observeEvent(input$dropDownFile, eventDropDown(input, output, session, values))
  observeEvent(event_data("plotly_click", source="plot0"), {
      print(paste('clicked on plot: 0'))
      values$highlightedValues = event_data("plotly_click", source="plot0")
      values$highlightedValues$plot = 0
  })  
  observeEvent(event_data("plotly_click", source="plot1"), {
    print(paste('clicked on plot: 1'))
    values$highlightedValues = event_data("plotly_click", source="plot1")
    values$highlightedValues$plot = 1
  })
 
  observeEvent(event_data("plotly_selected", source="plot0"), {
    print('selected')
    values$highlightedValues = event_data("plotly_selected", source="plot0")
  })
  observeEvent(values$highlightedValues, eventClick(session, values))
})
