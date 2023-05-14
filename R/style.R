`%>%` <- magrittr::`%>%`
markdown::smartypants("1/2 (c)\n")

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
        # shinydashboard hacks
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
        sprintf(".skin-black .sidebar-menu>li>.treeview-menu,
          .skin-black .content-wrapper,
          .nav-tabs-custom>.nav-tabs {
            background-color: %s;
        }", black),
        sprintf(".skin-black .nav-tabs-custom>.nav-tabs>li.active {
          border-top-color: %s;
        }", dark_gray),
        sprintf(".nav-tabs-custom>.nav-tabs {
          border-bottom-color: %s;
        }", dark_gray),
        sprintf(".nav-tabs-custom>.nav-tabs>li.active>a {
          border-right-color: %s;
          color: %s;
          background-color: %s;
        }", dark_gray, medium_gray, near_black),
        # inputs and reactable
        sprintf(".control-label, .eval-cell {
          font-family: %s;
        }", data_ff),
        sprintf(".nav-tabs-custom, .eval-cell, 
          .nav-tabs-custom>.tab-content, .ReactTable {
            background-color: %s;
        }", near_black),
        sprintf(".eval-header {
          color: %s;
          background-color: %s;
          border-bottom: 2px solid %s;
          font-family: %s;
          padding-top: 15px;
          padding-bottom: 15px;
        }", medium_gray, near_black, dark_gray, label_ff),
        sprintf(".control-label, .eval-cell {
          color: %s;
        }", medium_gray),
        sprintf(".eval-bar {
          color: %s;
          background-color: %s;
          border: 1px solid %s;
          height: 16px;
          text-align: left;
          white-space: nowrap;
          line-height: 1;
        }", dark_gray, pale_green, bright_green),
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
        }", dark_gray),
        # scrollbar
        "::-webkit-scrollbar {
          width: 8px;
        }",
        sprintf("::-webkit-scrollbar-thumb {
          background-color: %s;
          border-radius: 4px;
        }", medium_gray),
        sprintf("::-webkit-scrollbar-thumb:hover {
          background-color: %s;
        }", pale_green),
        sprintf("::-webkit-scrollbar-track {
          background-color: %s;
        }", near_black),
        # slider
        ".irs-from:after, .irs-to:after, .irs-single:after {
          border-top-color: transparent;
        }",
        sprintf(".irs-min, .irs-max {
          color: %s;
          background-color: %s;
        }", near_black, near_black),
        sprintf(".irs-from, .irs-to, .irs-single {
          color: %s;
          font-size: 14px;
          background-color: %s !important;
        }", bright_green, near_black),
        sprintf(".irs-min, .irs-max {
          color: %s;
          background: %s !important;
        }", near_black, near_black),
        sprintf(".irs-line-left, .irs-line-mid, .irs-line-right {
          background: %s !important;
          border-bottom: 1px solid %s;
          border-top: 1px solid %s;
        }", near_black, pale_green, pale_green),
        sprintf(".irs-bar, .irs-bar-edge {
          background: %s !important;
        }", bright_green),
        ".irs-bar-edge, .irs-line-left {
          border-top-left-radius: 3px;
          border-bottom-left-radius: 3px;
        }",
        sprintf(".irs-line-right {
          border-top-right-radius: 3px;
          border-bottom-right-radius: 3px;
          border-right: 1px solid %s;
        }", pale_green),
        ".irs-slider {
          top: 19px;
          background: transparent;
        }",
        ".btn.disabled {
          opacity: 25%;
        }",
        # action button
        sprintf(".btn-default {
          color: %s;
          background-color: %s;
          border-color: %s;
        }", bright_green, medium_gray, dark_gray),
        sprintf(".btn-default.hover, .btn-default:active, 
          .btn-default:focus, .btn-default:hover {
            color: %s;
            background-color: %s;
        }", bright_green, pale_green),
        # tooltip
        sprintf(".tippy-tooltip {
          color: %s;
          background-color: %s;
          font-size: 14px;
        })", bright_green, black),
        # generic (for markdown about page)
        sprintf("code {
          color: %s;
          background-color: %s;
        }", bright_green, black),
        sprintf(" body {
          color: %s;
        }", pale_green),
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
