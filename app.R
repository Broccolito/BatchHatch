library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyWidgets)
library(shinyalert)
library(shinyAce)
library(EBImage)

dashboardheader = dashboardHeader(title = "Batch Hatch", titleWidth = 600)
dashboardsidebar = dashboardSidebar(width = 600, div(br(),
                                                     box(width = 12, column(4, actionButton(inputId = "select_dir", label = "Select Directory")),
                                                         column(8, verbatimTextOutput(outputId = "working_directory"))),
                                                     box(width = 12, verbatimTextOutput(outputId = "wd_status")),
                                                     box(width = 12, aceEditor(outputId =  "term", 
                                                                               hotkeys = list(
                                                                                 help_key = "F1",
                                                                                 run_key = list(
                                                                                   win = "Ctrl-R|Ctrl-Shift-Enter",
                                                                                   mac = "CMD-ENTER|CMD-SHIFT-ENTER"
                                                                                 )
                                                                               )),
                                                     )
                                                     
))
dashboardbody = dashboardBody(div(
  useShinyalert(),
  plotOutput(outputId = "pic_overview", height = "600px")
))

ui = dashboardPage(
  title = "Batch Hatch",
  header = dashboardheader,
  sidebar = dashboardsidebar,
  body = dashboardbody,
)

server = function(input, output, session) {
  
  # Program at start
  wd = getwd()
  output$working_directory = renderText({
    text_output = ""
    text_output = paste(text_output, as.character(wd))
    return(text_output)
  })
  
  observeEvent(input$select_dir, {
    wd <<- choose.dir()
    output$working_directory = renderText({
      text_output = ""
      text_output = paste(text_output, as.character(wd))
      return(text_output)
    })
  })
  
  observeEvent(input$select_dir, {
    output$wd_status = renderText({
      picture_files = list.files(path = wd)
      picture_count = length(picture_files)
      current_picture = picture_files[1]
      text_output = paste0("File(s): ", picture_count, "     ",
                           "Current: ", current_picture)
      pic <<- readImage(files = paste0(wd, "\\", current_picture))
      output$pic_overview = renderPlot({
        plot(pic)
      })
      return(text_output)
    })
  })
  
  observeEvent(input$term_run_key, {
    tryCatch({
      eval(parse(text = isolate(input$term)))
    })
    output$pic_overview = renderPlot({
      plot(pic)
    })
  })
  

  
  onSessionEnded(function(x){stopApp()})
}

shinyApp(ui, server)