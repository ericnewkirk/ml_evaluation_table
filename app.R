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
          ),
          shinydashboard::menuSubItem(
            "About",
            "about"
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
                      width = 3,
                      shiny::div(
                        "Minimum Confidence:",
                        class = "control-label",
                        style = "text-align: right;"
                      ),
                      style = "margin-top: 15px;"
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
                        ticks = FALSE,
                        width = "100%"
                      )
                    ),
                    # update button
                    shiny::column(
                      width = 3,
                      shiny::actionButton(
                        "update_conf",
                        "Update",
                        width = "100%",
                        class = "btn btn-block btn-default"
                      ),
                      style = "margin-top: 12px;"
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
        ),
        shinydashboard::tabItem(
          "about",
          shinydashboard::tabBox(
            width = 8,
            shiny::tabPanel(
              title = "Background",
              # inputs
              shiny::fluidRow(
                shiny::column(
                  width = 12,
                  shiny::includeMarkdown("README.md")
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
  
  # load code
  purrr::walk(
    c("R/style.R", "R/reactable.R", "R/echarts.R"),
    source,
    local = TRUE
  )
  
  # add bar for slider handle
  shinyjs::runjs(
    "var span = $('<span />').attr({
      'style':'margin-left: 4px; border-left: 2px solid #74E39A;'
    }).html('&nbsp');
    $('.irs-slider').html(span);"
  )
  
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
