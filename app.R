black <- "#222D32"
aqua <- "#00B7EF"
dark_gray <- "#384246"
medium_gray <- "#989898"
bright_green <- "#74E39A"
medium_green <- "#24B256"
near_black <- "#333333"

app_ff <- "Consolas,'Helvetica Neue',Helvetica,Arial,sans-serif;"
input_ff <- "'Segoe UI',Helvetica,'Source Sans Pro',Arial,sans-serif;"

#' ML Evaluation Table Demo
#'
#' @return shiny application
#' @export
#' 
#' @importFrom magrittr %>%
#'
#' @examples
#' 
#' \donttest{
#' 
#' ml_evaluation_table::ml_eval_app()
#' 
#' }
#' 
ml_eval_app <- function() {
  
  ui <- function(request) {
    shinydashboard::dashboardPage(
      shinydashboard::dashboardHeader(title = "ML Evaluation Table"),
      shinydashboard::dashboardSidebar(
        shinydashboard::sidebarMenu(
          id = "sb_tabs",
          shinydashboard::menuItem(
            "Train",
            tabName = "train"
          ),
          shinydashboard::menuItem(
            "Classify",
            tabName = "class"
          ),
          shinydashboard::menuItem(
            "Evaluate",
            tabName = "eval",
            startExpanded = TRUE,
            shinydashboard::menuSubItem(
              "Evaluation Table",
              "eval_table",
              selected = TRUE
            ),
            shinydashboard::menuSubItem(
              "Predicted Accuracy",
              "eval_pred"
            )
          )
        )
      ),
      shinydashboard::dashboardBody(
        shinyWidgets::chooseSliderSkin("HTML5", color = near_black),
        shiny::includeCSS("./www/ml_evaluation_table.css"),
        shinydashboard::tabItems(
          shinydashboard::tabItem(
            "eval_table",
            shinydashboard::tabBox(
              width = 12,
              shiny::tabPanel(
                title = "Observed Accuracy Table",
                shiny::fluidRow(
                  shiny::column(
                    width = 4,
                    shiny::sliderInput(
                      "eval_table_conf",
                      "Minimum Confidence:",
                      min = 0,
                      max = 1,
                      value = 0,
                      step = 0.01,
                      round = 2,
                      width = "100%"
                    )
                  ),
                  shiny::column(width = 8)
                ),
                shiny::fluidRow(
                  shiny::column(
                    width = 12,
                    reactable::reactableOutput("eval_table") %>% 
                      with_spinner()
                  )
                )
              )
            )
          )
        )
      ),
      skin = "black"
    )
  }
  
  server = function(input, output, session) {
    
    output$eval_table <- reactable::renderReactable({
      
      eval_table(sub_default(input$eval_table_conf, 0))
       
    })
    
    shiny::observeEvent(input$sp_link, {
      
      shiny::showModal(shiny::modalDialog(
        title = NULL,
        echarts4r::echarts4rOutput("eval_plot") %>% 
          with_spinner(),
        size = "l",
        easyClose = TRUE,
        footer = NULL
      ))
      
    })
    
    output$eval_plot <- echarts4r::renderEcharts4r({
      embedded_plot(input$sp_link, sub_default(input$eval_table_conf, 0))  
    })
    
    
  }
  
  shiny::shinyApp(ui, server)
  
}
