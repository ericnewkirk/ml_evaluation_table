e_dark_zoom <- function(e, start = 0, end = nrow(e$x$data[[1]]) - 1) {
  
  e %>% 
    echarts4r::e_datazoom(
      startValue = start,
      endValue = end,
      dataBackground = list(
        lineStyle = list(color = medium_green),
        areaStyle = list(color = medium_green)
      ),
      textStyle = list(color = medium_gray)
    ) %>%
    echarts4r::e_toolbox_feature(
      feature = "saveAsImage",
      emphasis = list(
        iconStyle = list(textAlign = "right")
      )
    )
  
}

e_zoom_cb <- function(e, cutoff = 0.25, n_ser = 1) {

  js <- paste0(
    "function(event) {
    
      var span = (event.end - event.start) / 100;
      var gb;
      var ng;
      var angle;
      var overflow;
      var lbl;
      
      if (span > ", cutoff, ") {
        gb = 210;
        ng = 120;
        angle = 45;
        overflow = 'truncate';
        lbl = false;
      } else {
        gb = 120;
        ng = 30;
        angle = 0;
        overflow = 'none';
        lbl = true;
      }
      
      var option = {
        'grid' : {
          'bottom' : gb
        },
        'xAxis' : {
          'nameGap' : ng,
          'axisLabel' : {
            'rotate' : angle,
            'overflow' : overflow
          }
        }
      };
      
      option.series = [
        ", paste0(rep("{'label' : {'show' : lbl}}", n_ser), collapse = ", "), "
      ]
      
      this.setOption(option);
      
    }"
  )
  
  e %>%
    echarts4r::e_on(
      "dataZoom",
      js,
      event = "datazoom"
    )
  
}

e_series_data <- function(e, series, data, nm) {
  
  x <- e$x$opts$series[[series]]$data
  
  fn <- function(x, y) {
    z <- x
    z[[nm]] = y
    z
  }
  
  x <- purrr::map2(x, data, fn)
  
  e$x$opts$series[[series]]$data <- x
  
  e
  
}

logit_plot <- function(comp,
                       logit_model,
                       fixed = list()) {
  
  ttl <- logit_title(logit_model, fixed)
  
  x <- pred_logit(logit_model, fixed, min_x = 0, max_x = 1)
  
  lbl <- title_case(names(x))
  
  if (inherits(x[[1]], c("character", "factor"))) {
    e_fn <- function(e) {
      echarts4r::e_bar_(e,
        names(x)[2],
        name = lbl[2],
        label = list(
          show = TRUE,
          position = "top"
        ),
        itemStyle = list(color = bright_green)
      ) %>% 
        e_dark_zoom(end = min(nrow(x) - 1, 7)) %>% 
        e_zoom_cb(cutoff = 0.2, n_ser = 1)
    }
  } else {
    e_fn <- function(e) {
      echarts4r::e_area_(e,
        names(x)[2],
        name = lbl[2],
        itemStyle = list(color = bright_green)
      ) %>% 
        e_dark_zoom()
    }
  }
  
  x %>% 
    echarts4r::e_charts_(
      names(x)[1],
      grid = list(bottom = 100)
    ) %>% 
    e_fn() %>% 
    e_dark(lbl[1], lbl[2]) %>% 
    echarts4r::e_title(ttl, textStyle = list(color = medium_gray)) %>% 
    echarts4r::e_tooltip(
      formatter = htmlwidgets::JS(paste0(
        "
          function(params){
            var tt = '", lbl[1], ": <strong>' + params.value[0] + '</strong>';
            tt += '<br/>' + params.marker + params.seriesName + ': ' + 
              (params.value[1] * 100).toFixed(2) + '%';
            return(tt);
          }
        "
      ))
    )
  
}

embedded_plot <- function(species, min_conf = 0) {
  
  eval %>%
    dplyr::select(-dplyr::any_of(c("ImgPath"))) %>%
    dplyr::filter(
      ModelConfidence >= min_conf,
      Species == species
    ) %>%
    dplyr::group_by(Species, ModelID) %>%
    dplyr::summarize(
      n = dplyr::n(),
      CorrectCount = sum(Match),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(n)) %>% 
    dplyr::mutate(
      IncorrectCount = n - CorrectCount,
      Percent = round(n * 100 / sum(n), 2)
    ) %>%
    echarts4r::e_charts(
      ModelID,
      width = "80%",
      grid = list(
        left = 120,
        bottom = 120
      )
    ) %>%
    echarts4r::e_bar(
      CorrectCount,
      legend = FALSE,
      itemStyle = list(color = bright_green),
      stack = "x",
      label = list(
        show = TRUE,
        position = "top",
        formatter = htmlwidgets::JS("
          function(params){
            if (params.data.value[1] > 0) {
              return(Number(params.data.value[1]).toLocaleString());
            } else {
              return('')
            }
          }
        ")
      ),
      z = 3
    ) %>%
    e_series_data(1, .$x$data[[1]]$Percent, "Percent") %>%
    echarts4r::e_bar(
      IncorrectCount,
      legend = FALSE,
      itemStyle = list(color = medium_gray),
      stack = "x",
      label = list(
        show = TRUE,
        position = "top",
        formatter = htmlwidgets::JS("
          function(params){
            if (params.data.value[1] > 0) {
              return(Number(params.data.value[1]).toLocaleString());
            } else {
              return('')
            }
          }
        ")
      )
    ) %>%
    e_series_data(2, .$x$data[[1]]$Percent, "Percent") %>%
    echarts4r::e_x_axis(
      name = "Model ID",
      nameLocation = "center",
      nameGap = 30,
      nameTextStyle = list(
        fontSize = 18,
        color = bright_green
      ),
      axisLabel = list(
        color = medium_gray
      ),
      axisLine = list(
        lineStyle = list(color = dark_gray)
      ),
      splitLine = list(
        lineStyle = list(color = dark_gray)
      )
    ) %>%
    echarts4r::e_y_axis(
      name = "Photos",
      nameLocation = "center",
      nameRotate = 90,
      nameGap = 50,
      nameTextStyle = list(
        fontSize = 18,
        color = bright_green
      ),
      axisLabel = list(
        color = medium_gray
      ),
      axisLine = list(
        lineStyle = list(color = medium_gray)
      ),
      splitLine = list(
        lineStyle = list(color = dark_gray)
      )
    ) %>% 
    echarts4r::e_color(background = near_black) %>% 
    echarts4r::e_title(
      sprintf("Model IDs for %s Photos", species),
      textStyle = list(color = medium_gray)
    ) %>% 
    echarts4r::e_tooltip(
      formatter = htmlwidgets::JS(
        "
          function(params){
            var tt = 'Model ID: <strong>' + params.value[0] + 
              '</strong>';
            tt += '<br/>' + params.marker + '  ' +
              Number(params.value[1]).toLocaleString() + ' photos' + 
              ' (' + params.data.Percent + '%)';
            return(tt);
          }
       "
      )
    ) %>% 
    e_dark_zoom(end = min(c(nrow(.$x$data[[1]]) - 1, 6))) %>%
    e_zoom_cb(cutoff = 0.25, n_ser = 2)
  
}
