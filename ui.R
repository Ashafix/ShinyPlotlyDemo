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
      inputDropDown()
    ),
    mainPanel(
      plotlyOutput("plot0"),
      plotlyOutput("plot1")
    )
  )
}

shinyUI(
  fluidPage(
    useShinyjs(),
    inputSideBar()
    )
)
