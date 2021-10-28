################################################################################
# Plot data
################################################################################

# get species value from index - much faster than using calc_eval repeatedly
eval_species <- function(index) {
  unique(eval$Species) %>% 
    `[`(order(.)) %>% 
    `[`(index)
}

# filter eval to a single species and summarize for plot
eval_plot_data <- function(index, min_conf = 0) {
  
  eval %>%
    dplyr::select(-dplyr::any_of(c("ImgPath"))) %>%
    dplyr::filter(
      ModelConfidence >= min_conf,
      Species == eval_species(index)
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
    )
  
}

# add column to series data for js rendering
e_series_data <- function(e, series, data, nm) {
  
  x <- e$x$opts$series[[series]]$data
  
  fn <- function(x, y) {
    z <- x
    z[[nm]] <- y
    z
  }
  
  x <- purrr::map2(x, data, fn)
  
  e$x$opts$series[[series]]$data <- x
  
  e
  
}

################################################################################
# Plot formatting
################################################################################

# add bar series
e_dark_bar <- function(e, col, opts, color, z = 1) {
  
  e %>% 
    echarts4r::e_bar_(
      col,
      legend = FALSE,
      itemStyle = list(color = color),
      stack = "x",
      label = list(
        show = opts$lbl,
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
      z = z
    )
  
}

# format x axis
e_dark_x <- function(e, opts) {
  
  e %>% 
    echarts4r::e_x_axis(
      name = "Model ID",
      nameLocation = "center",
      nameGap = opts$ng,
      nameTextStyle = list(
        fontSize = 18,
        color = bright_green
      ),
      axisLabel = list(
        color = medium_gray,
        rotate = opts$angle,
        overflow = opts$overflow
      ),
      axisLine = list(
        lineStyle = list(color = dark_gray)
      ),
      splitLine = list(
        lineStyle = list(color = dark_gray)
      )
    )
  
}

# format y axis
e_dark_y <- function(e) {
  
  e %>% 
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
    )
  
}

# add datazoom and buttons
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

# add zoom callback to change axis formatting
e_zoom_cb <- function(e, cutoff = 6, n_ser = 1) {
  
  js <- sprintf(
    "function(event) {
    
      // get current zoom level (number of x values visible)
      var option = this.getOption();
      var span = option.dataZoom[0].endValue - 
        option.dataZoom[0].startValue + 1;
      
      var gb; // gridBottom
      var ng; // nameGap
      var angle; // axis label angle
      var overflow; // text overflow option
      var lbl; // show data labels
      
      // set options based on number of values
      if (span > %s) {
        gb = 150;
        ng = 60;
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
      
      // combine options into list
      option = {
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
      
      // add series array
      option.series = [
        %s
      ]
      
      // apply new options
      this.setOption(option);
      
    }",
    cutoff,
    paste0(rep("{'label' : {'show' : lbl}}", n_ser), collapse = ", ")
  )
  
  # add callback to echarts object
  e %>%
    echarts4r::e_on(
      "dataZoom",
      js,
      event = "datazoom"
    )
  
}

################################################################################
# Full plot
################################################################################

# create echarts plot
eval_plot <- function(index, min_conf = 0) {
  
  # get data
  x <- eval_plot_data(index, min_conf)
  
  # get options based on number of rows
  opts <- purrr::when(
    x,
    nrow(.) < 7
      ~ list(
        gb = 120,
        ng = 30,
        angle = 0,
        overflow = "none",
        lbl = TRUE
      ),
    ~ list(
      gb = 150,
      ng = 60,
      angle = 45,
      overflow = "truncate",
      lbl = FALSE
    )
  )
  
  # create echarts object
  x %>%
    echarts4r::e_charts(
      ModelID,
      width = "100%",
      grid = list(
        left = 120,
        bottom = opts$gb
      )
    ) %>%
    # add correct series
    e_dark_bar("CorrectCount", opts, bright_green, 3) %>% 
    e_series_data(1, .$x$data[[1]]$Percent, "Percent") %>%
    # add incorrect series
    e_dark_bar("IncorrectCount", opts, medium_gray) %>% 
    e_series_data(2, .$x$data[[1]]$Percent, "Percent") %>%
    # format axes
    e_dark_x(opts) %>% 
    e_dark_y() %>% 
    echarts4r::e_color(background = near_black) %>% 
    # add title
    echarts4r::e_title(
      sprintf("Model IDs for %s Photos", eval_species(index)),
      textStyle = list(color = medium_gray)
    ) %>% 
    # add tooltip
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
    # add datazoom, buttons, and callback
    e_dark_zoom() %>%
    e_zoom_cb(cutoff = 6, n_ser = 2)
  
}
