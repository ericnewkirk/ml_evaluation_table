# define UI
ui <- function(request) {
  
  source("R/style.R", local = TRUE)
  
  shinydashboard::dashboardPage(
    # header
    shinydashboard::dashboardHeader(title = "ML Evaluation Table"),
    # sidebar
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
      # setup
      shinyWidgets::chooseSliderSkin("Modern", color = near_black),
      shinyjs::useShinyjs(),
      ml_eval_css(),
      # table page
      shinydashboard::tabItems(
        shinydashboard::tabItem(
          "eval_table",
          shinydashboard::tabBox(
            width = 12,
            shiny::tabPanel(
              title = "Model Performance",
              # inputs
              shiny::fluidRow(
                shiny::column(width = 6),
                shiny::column(
                  width = 6,
                  shiny::fluidRow(
                    # label in its own column for inline layout
                    shiny::column(
                      width = 4,
                      shiny::div(
                        "Minimum Confidence:",
                        class = "control-label",
                        style = "text-align: right;"
                      )
                    ),
                    # slider
                    shiny::column(
                      width = 6,
                      shiny::sliderInput(
                        "eval_table_conf",
                        label = NULL,
                        min = 0,
                        max = 1,
                        value = 0,
                        step = 0.01,
                        round = 2,
                        ticks = FALSE
                      )
                    ),
                    # update button
                    shiny::column(
                      width = 2,
                      shiny::actionButton(
                        "update_conf",
                        "Update",
                        width = "100%",
                        class = "btn btn-block btn-default"
                      )
                    )
                  )
                )
              ),
              # table
              shiny::fluidRow(
                shiny::column(
                  width = 12,
                  reactable::reactableOutput(
                    "eval_table",
                    height = "75vh"
                  ) %>% 
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

# create server  
server = function(input, output, session) {
  
  purrr::walk(
    c("R/style.R", "R/echarts.R", "R/reactable.R"),
    source,
    local = TRUE
  )
  
  load("data/eval.rda")
  
  # confidence slider change
  shiny::observeEvent(input$eval_table_conf, {
    # enable update button
    shinyjs::enable(id = "update_conf")
  })
  
  # reactable render function
  output$eval_table <- reactable::renderReactable({
    
    # fire on update button click
    input$update_conf
    
    # disable update button
    shinyjs::disable(id = "update_conf")
    
    # default minimum confidence to 0
    min_conf <- shiny::isolate({
      purrr::when(
        input$eval_table_conf,
        is.null(.) ~ 0,
        ~ .
      )
    })
    
    # draw table
    eval_table(min_conf)
     
  })
  
}

# return the app
shiny::shinyApp(ui, server)
