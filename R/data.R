utils::globalVariables(c(
  "eval"
))

#' ML Evaluation Raw Data
#'
#' A dataset containing ML IDs (top 1) and confidence
#'   alongside human observer IDs for ~260,000 photos from a
#'   camera trapping survey of North American wildlife
#' IDs have been anonymized using common farm animals plus some
#'   fish and insects when I was running out of ideas
#' Image file paths have also been anonymized using an entirely
#'   fictitious sampling design of 20 camera locations
#'   
#' @format A data frame with 257,810 rows and 6 columns:
#' \describe{
#'   \item{ImgPath}{Full path to the image file on disk}
#'   \item{Species}{ID from human observer}
#'   \item{ModelID}{Top guess from pre-trained neural network}
#'   \item{ModelSpecies}{Human ID species corresponding to the ModelID -
#'     needed because photos used to train the network were tagged
#'     differently than the photos used here}
#'   \item{ModelConfidence}{Confidence reported by neural network for the
#'     top guess}
#'   \item{Match}{0 or 1 indicating if ML ID and human ID match}
#' }
#' 
"eval"