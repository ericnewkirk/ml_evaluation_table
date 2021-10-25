eval_table_bar = function(label, width) {
  
  if (is.na(label) || is.null(label)) {
    return(htmltools::div())
  }
  
  bar <- htmltools::div(
    title = as.character(round(label, 2)),
    style = list(
      background = bright_green,
      color = "#FFFFFF",
      width = width,
      height = "16px",
      textAlign = "left",
      whiteSpace = "nowrap"
    ),
    label
  )
  
  chart <- htmltools::div(
    style = list(
      flexGrow = 1,
      background = medium_gray,
      color = "#FFFFFF",
      textAlign = "right",
      display = "inline"
    ),
    bar
  )
  
  htmltools::div(
    style = list(
      display = "flex",
      alignItems = "center"
    ),
    chart
  )
  
}

c_col <- function(name) {
  reactable::colDef(
    name = name,
    align = "right",
    width = 80,
    style = list(color = medium_green),
    cell = function(value) {
      format(
        value,
        big.mark = ",",
        scientific = FALSE
      )
    }
  )
}

inc_col <- function(name) {
  reactable::colDef(
    name = name,
    align = "left",
    width = 80,
    style = list(color = medium_gray),
    cell = function(value) {
      format(
        value,
        big.mark = ",",
        scientific = FALSE
      )
    }
  )
}

def_col <- function(...) {
  reactable::colDef(
    align = "center",
    headerClass = "eval-header",
    class = "eval-cell",
    ...
  )
}

eval_table <- function(min_conf) {
  
  calc_eval(min_conf) %>% 
    reactable::reactable(
      defaultSortOrder = "desc",
      defaultColDef = def_col(maxWidth = 250),
      pagination = FALSE,
      columns = list(
        n = reactable::colDef(
          name = "Total Photos",
          cell = function(value) {
            format(
              value,
              big.mark = ",",
              scientific = FALSE
            )
          }
        ),
        true_pos = c_col("True +"),
        false_neg = inc_col("False -"),
        true_neg = c_col("True -"),
        false_pos = inc_col("False +"),
        accuracy = reactable::colDef(
          name = "Accuracy",
          minWidth = 80,
          cell = function(value) {
            bar_w <- paste0(value * 100, "%")
            eval_table_bar(value, bar_w)
          },
          header = shiny::div(
            "Accuracy",
            shiny::tags$abbr(
              style = "cursor: help; margin-left: 10px;",
              title = "(true positives + true negatives) / total photos",
              "?"
            )
          )
        ),
        precision = reactable::colDef(
          name = "Precision",
          minWidth = 80,
          cell = function(value) {
            bar_w <- paste0(value * 100, "%")
            eval_table_bar(value, bar_w)
          },
          header = shiny::div(
            "Precision",
            shiny::tags$abbr(
              style = "cursor: help; margin-left: 10px;",
              title = "true positives / (true positives + false positives)",
              "?"
            )
          )
        ),
        recall = reactable::colDef(
          name = "Recall",
          minWidth = 80,
          cell = function(value) {
            bar_w <- paste0(value * 100, "%")
            eval_table_bar(value, bar_w)
          },
          header = shiny::div(
            "Recall",
            shiny::tags$abbr(
              style = "cursor: help; margin-left: 10px;",
              title = "true positives / (true positives + false negatives)",
              "?"
            )
          )
        )
      ),
      details = function(index) {
        eval_plot(index, min_conf)
      }
    )
  
}

eval_plot <- function(index, min_conf) {
  
  shiny::div(
    embedded_plot(eval_species(index), min_conf),
    style = "padding-left: 10%;"
  )
  
}
