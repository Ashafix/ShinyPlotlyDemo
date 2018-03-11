library(shiny)
library(shinyBS)
library(plotly)
library(shinyjs)

source('Configuration.R')

getFiles <- function()
{
  options <- list.files(appDir, pattern='Simple')
  return(options)
}

inputDropDown <- function()
{
  selectInput("dropDownFile", "Select a file", getFiles())
}

inputSideBar <- function()
{
  sidebarLayout(
    sidebarPanel(
      actionButton("do", "Click Me"),
      inputDropDown()
    ),
    mainPanel(
      plotlyOutput("plot"),
      plotlyOutput("plot_reacting")
    )
  )
}

shinyUI(
  fluidPage(
    useShinyjs(),
    #extendShinyjs(text=javascript),
    inputSideBar()
    )
)
