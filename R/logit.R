#' @importFrom stats predict
#' @importFrom rlang :=
#' 
pred_logit <- function(logit_model,
                       fixed = list(),
                       n = 101L,
                       round_y = 3,
                       min_x = NULL,
                       max_x = NULL) {
  
  logit_vars <- all.vars(logit_model$terms)
  resp_var <- logit_vars[attr(logit_model$terms, "response")]
  plot_var <- logit_vars[!logit_vars %in% c(names(fixed), resp_var)]
  
  if (length(plot_var) > 1) {
    return(tibble::tibble())
  }
  
  if (inherits(logit_model$model[[plot_var]], "factor")) {
    nf = list(logit_model$xlevels[[plot_var]])
  } else {
    if (is.null(min_x)) {
      min_x <- min(logit_model$model[[plot_var]], na.rm = TRUE)
    }
    if (is.null(max_x)) {
      max_x <- max(logit_model$model[[plot_var]], na.rm = TRUE)
    }
    nf <- list(as.numeric(seq(from = min_x, to = max_x, length.out = n)))
  }
  
  names(nf) <- plot_var
    
  new_data <- nf %>% 
    tibble::as_tibble() %>% 
    dplyr::bind_cols(fixed)
  
  new_data %>% 
    dplyr::mutate(
      "{resp_var}Probability" := round(
        predict(logit_model, newdata = ., type = "response"),
        round_y
      )
    ) %>% 
    dplyr::select(-dplyr::any_of(names(fixed)))
  
}

# pred_logit(logit_c, min_y = 0, max_y = 1)
# pred_logit(logit_c, n = 151L, min_y = 0, max_y = 1)
# 
# pred_logit(
#   logit_m,
#   fixed = list(ModelID = "snowshoe_hare"),
#   min_y = 0,
#   max_y = 1
# )
# pred_logit(
#   logit_h,
#   fixed = list(HumanID = "Snowshoe Hare"),
#   min_y = 0,
#   max_y = 1
# )

logit_title <- function(logit_model, fixed) {
  
  fx <- paste(names(fixed), fixed, sep = " = ")
  
  ttl <- rlang::quo_text(logit_model$formula)
  
  purrr::when(
    fx,
    length(.) > 0 ~ sprintf("%s (%s)", ttl, fx),
    ~ ttl
  )
  
}
