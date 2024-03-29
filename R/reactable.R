load("data/eval.rda")

calc_eval <- function(min_conf) {
  
  eval %>% 
    dplyr::group_by(Species) %>% 
    dplyr::summarize(
      n = dplyr::n(),
      true_pos = sum(
        dplyr::case_when(
          ModelConfidence < min_conf ~ 0L,
          TRUE ~ as.integer(Match)
        )
      ),
      false_neg = n - true_pos
    ) %>% 
    dplyr::mutate(
      false_pos = purrr::map_int(
        Species,
        ~ eval %>% 
          dplyr::filter(
            Match == 0,
            ModelSpecies == .x,
            ModelConfidence >= min_conf
          ) %>% 
          nrow()
      ),
      true_neg = purrr::map_int(
        Species,
        ~ eval %>% 
          dplyr::filter(
            Species != .x,
            ModelSpecies != .x | ModelConfidence < min_conf
          ) %>% 
          nrow()
      ),
      accuracy = (true_pos + true_neg) / nrow(eval),
      precision = tidyr::replace_na(
        true_pos / (true_pos + false_pos),
        0
      ),
      recall = true_pos / n
    )
  
}

eval_table_bar = function(label, width) {
  
  if (is.na(label) || is.null(label)) {
    return(htmltools::div())
  }
  
  bar <- htmltools::div(
    class = "eval-bar",
    style = list(
      width = width
    ),
    label
  )
  
  chart <- htmltools::div(
    class = "eval-bar-bg",
    bar
  )
  
  htmltools::div(
    class = "eval-bar-wrapper",
    chart
  )
  
}

c_col <- function(name, align = "right", ...) {
  reactable::colDef(
    name = name,
    align = align,
    width = 80,
    style = list(color = bright_green),
    cell = function(value) {
      format(
        value,
        big.mark = ",",
        scientific = FALSE
      )
    },
    ...
  )
}

inc_col <- function(name, align = "left", ...) {
  reactable::colDef(
    name = name,
    align = align,
    width = 80,
    style = list(color = medium_gray),
    cell = function(value) {
      format(
        value,
        big.mark = ",",
        scientific = FALSE
      )
    },
    ...
  )
}

def_col <- function(...) {
  reactable::colDef(
    align = "center",
    headerClass = "eval-header",
    class = "eval-cell",
    footerClass = "eval-cell",
    ...
  )
}

eval_table <- function(min_conf) {
  
  calc_eval(min_conf) %>% 
    reactable::reactable(
      defaultSortOrder = "desc",
      defaultColDef = def_col(maxWidth = 250),
      pagination = FALSE,
      onClick = "expand",
      height = "75vh",
      columns = list(
        Species = reactable::colDef(
          style = list(
            color = bright_green,
            fontWeight = 600
          ),
          footer = "Total",
          footerStyle = list(
            color = bright_green,
            fontWeight = 600
          )
        ),
        n = reactable::colDef(
          name = "Total Photos",
          cell = function(value) {
            format(
              value,
              big.mark = ",",
              scientific = FALSE
            )
          },
          footer = htmlwidgets::JS("function(colInfo) {
            var total = 0
            colInfo.data.forEach(function(row) {
              total += row[colInfo.column.id]
            })
            return total.toLocaleString()
          }"),
          footerStyle = list(
            color = medium_gray,
            fontWeight = 600
          )
        ),
        true_pos = c_col(
          "True +",
          footer = htmlwidgets::JS("function(colInfo) {
            var total = 0;
            colInfo.data.forEach(function(row) {
              total += row[colInfo.column.id];
            })
            return total.toLocaleString();
          }"),
          footerStyle = list(
            color = bright_green,
            fontWeight = 600
          )
        ),
        false_neg = inc_col("False -"),
        true_neg = c_col("True -", "left"),
        false_pos = inc_col("False +", "right"),
        accuracy = reactable::colDef(
          name = "Accuracy",
          minWidth = 80,
          cell = function(value) {
            bar_w <- paste0(value * 100, "%")
            eval_table_bar(value, bar_w)
          },
          header = shiny::div(
            tippy::tippy(
              "Accuracy",
              "(true positives + true negatives) / total photos",
              placement = "top",
              flip = FALSE
            )
          ),
          footer = htmlwidgets::JS("function(colInfo) {
            var total = 0;
            var correct = 0;
            colInfo.data.forEach(function(row) {
              total += row['n'];
              correct += row['true_pos'];
            })
            return (correct * 100 / total).toFixed(2) + '%';
          }"),
          footerStyle = list(
            color = bright_green,
            fontWeight = 600
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
            tippy::tippy(
              "Precision",
              "true positives / (true positives + false positives)",
              placement = "top",
              flip = FALSE
            )
          ),
          footer = htmlwidgets::JS("function(colInfo) {
            var total = 0;
            var correct = 0;
            colInfo.data.forEach(function(row) {
              total += (row['true_pos'] + row['false_pos']);
              correct += row['true_pos'];
            })
            return (correct * 100 / total).toFixed(2) + '%';
          }"),
          footerStyle = list(
            color = bright_green,
            fontWeight = 600
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
            tippy::tippy(
              "Recall",
              "true positives / (true positives + false negatives)",
              placement = "top",
              flip = FALSE
            )
          )
        )
      ),
      details = function(index) {
        eval_plot(index, min_conf)
      }
    )
  
}
