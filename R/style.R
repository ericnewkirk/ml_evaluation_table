`%>%` <- magrittr::`%>%`
load("data/eval.rda")

# app colors
black <- "#222D32"
aqua <- "#00B7EF"
dark_gray <- "#384246"
medium_gray <- "#989898"
bright_green <- "#74E39A"
medium_green <- "#24B256"
pale_green <- "#8BA795"
near_black <- "#333333"

# app fonts
label_ff <- "'Source Sans Pro','Helvetica Neue',Helvetica,Arial,sans-serif;"
data_ff <- "'Segoe UI',Helvetica,'Source Sans Pro',Arial,sans-serif;"

# css as a style tag - kind of a weird way to do this but oh well
ml_eval_css <- function() {
  
  shiny::tags$style(
    shiny::HTML(
      paste(
        sprintf(".skin-black .sidebar-menu>li.active>a,
          .skin-black .treeview-menu>li.active>a {
          color: %s;
          border-left-color: %s;
        }", bright_green, bright_green),
        sprintf(".skin-black .sidebar-menu>li:hover>a,
          .skin-black .treeview-menu>li>a:hover {
          color: %s;
          border-left-color: %s;
        }", pale_green, pale_green),
        sprintf(".skin-black .sidebar a, .skin-black .treeview-menu>li>a {
          color: %s;
        }", dark_gray),
        sprintf(".skin-black .sidebar-menu>li>.treeview-menu, .skin-black .content-wrapper {
          background-color: %s;
        }", black),
        sprintf(".skin-black .nav-tabs-custom>.nav-tabs>li.active{
          border-top-color: %s;
        }", medium_gray),
        sprintf(".control-label, .eval-cell {
          font-family: %s;
        }", data_ff),
        sprintf(".control-label, .eval-bar {
          color: %s;
        }", dark_gray),
        sprintf(".nav-tabs-custom, .eval-cell {
          background-color: %s;
        }", dark_gray),
        sprintf(".eval-header {
          color: %s;
          font-family: %s;
        }", medium_green, label_ff),
        sprintf(".eval-cell {
          color: %s;
        }", medium_gray),
        sprintf(".eval-bar {
          background-color: %s;
          height: 16px;
          text-align: left;
          white-space: nowrap;
        }", bright_green),
        sprintf(".eval-bar-bg {
          flex-grow: 1;
          background-color: %s;
          display: inline;
        }", medium_gray),
        ".eval-bar-wrapper {
          display: flex;
          align-items: center;
        }",
        sprintf(".rt-expander:after {
          border-top: 7px solid %s;
        }", bright_green),
        sprintf(".rt-td {
          border-top: 1px solid %s;
        }", near_black),
        sep = "\n"
      )
    )
  )
  
}

# wrapper for spinner options
with_spinner <- function(x) {
  
  x %>% 
    shinycssloaders::withSpinner(
      type = 8,
      color = bright_green,
      hide.ui = FALSE
    )
}
