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

eval_species <- function(index) {
  unique(eval$Species) %>% 
    `[`(order(.)) %>% 
    `[`(index)
}


sub_default <- function(x, def) {
  if (shiny::isTruthy(x)) x else def
}

with_spinner <- function(x) {
  
  x %>% 
    shinycssloaders::withSpinner(
      type = 8,
      color = "#74E39A"
    )
}

title_case <- function(x) {
  
  gsub("([a-z])([A-Z])", "\\1 \\2", x)
  
}
