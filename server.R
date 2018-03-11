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
  return(js)
}

eventButton <- function(session, values) 
{
  shinyjs::runjs(highlightValues(values$highlightedValues))
  showModal(modalDialog(
    numbersToMessage(values$highlightedValues)
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

definedPlot <- function(values)
{
  print('plotting defined plot')
  renderPlotly({
    plot_ly(type='scatter', x=values$x, y=values$y, source="plot", mode='markers') %>% 
      add_trace(type='scatter', x=c(0), y=c(0), mode='markers', name="", visible=FALSE) %>% 
      layout(showlegend=FALSE)
  })
}

eventDropDown <- function(input, output, session, values)
{
  print('dropDown event')
  values$points <- fread(paste(appDir, input$dropDownFile, sep="/"))
  values$highlightedValues = NULL
  output$plot <- definedPlot(values$points)
  output$plot_reacting <- reactingPlot(values$highlightedValues)
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
    valueRange <- seq(from=x[index] * 0.8, to=x[index] * 1.2, by=.01)
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
      layout(xaxis=list(range=c(0, 10)),
      yaxis=list(range=c(0, 10)))
  })
}

shinyServer(function(input, output, session) {
  values <- reactiveValues()
  values$highlightedValues = list(x="", y="")
  output$plot <- definedPlot(values$points)
  observeEvent(input$do, eventButton(session, values))
  observeEvent(input$dropDownFile, eventDropDown(input, output, session, values))
  observeEvent(event_data("plotly_click", source="plot"), {
    print('clicked')
    values$highlightedValues = event_data("plotly_click", source="plot")
    output$plot_reacting <- reactingPlot(values$highlightedValues)
  })
  observeEvent(event_data("plotly_selected", source="plot"), {
    print('selected')
    values$highlightedValues = event_data("plotly_selected", source="plot")
    output$plot_reacting <- reactingPlot(values$highlightedValues)
  })
  output$plot_reacting <- reactingPlot(NULL)
  observeEvent(values$highlightedValues, eventButton(session, values))
})
