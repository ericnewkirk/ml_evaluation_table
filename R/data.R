utils::globalVariables(c(
  "comp", "comp_gr", "id_comp",
  "logit_c", "logit_h", "logit_m",
  "MatchUpper", "MatchLower", "MatchProbability"
))

#' MLWIC Evaluation Raw Data
#'
#' A dataset containing MLWIC IDs (top 1) and confidence 
#'   alongside human observer IDs for ~260,000 photos from GYA
#' Provides data for viewing individual photos from reactable, 
#'   and is the basic data used to compile the other data objects
#'   
#' @format A data frame with 258,946 rows and 6 columns:
#' \describe{
#'   \item{ImgPath}{Full path to the image file on disk}
#'   \item{FileName}{Filename of the image file}
#'   \item{HumanID}{ID from human observer via CPW Photo Warehouse}
#'   \item{ModelID}{Top guess from MLWIC}
#'   \item{ModelConfidence}{Confidence for the top guess from MLWIC}
#'   \item{Match}{0 or 1 indicating if MLWIC ID and human ID match}
#' }
#' 
"comp"

#' MLWIC Evaluation Data Summary
#'
#' A dataset summarizing MLWIC performance by human observer ID 
#'   for ~260,000 photos from GYA
#' Provides top level records for evaluation reactable and data for 
#'   evaluation plot
#'   
#' @format A data frame with 39 rows and 8 columns:
#' \describe{
#'   \item{HumanID}{ID from human observer via CPW Photo Warehouse}
#'   \item{n_total}{Number of images in dataset with this human ID}
#'   \item{n_match}{Number of images identified correctly by MLWIC}
#'   \item{match_pct}{Percentage of photos identified correctly by MLWIC}
#'   \item{n_over_90}{Number of images with MLWIC confidence > 0.9}
#'   \item{n_under_50}{Number of images with MLWIC confidence < 0.5}
#'   \item{match_over_90}{Number of images identified correctly by MLWIC with confidence > 0.9}
#'   \item{match_under_50}{Number of images identified correctly by MLWIC with confidence < 0.5}
#' }
#' 
"comp_gr"

#' MLWIC Evaluation Data Summary Detail
#'
#' A dataset summarizing MLWIC performance by human observer ID 
#'   and model ID for ~260,000 photos from GYA
#' Provides second level records for evaluation reactable
#'
#' @format A data frame with 660 rows and 4 columns:
#' \describe{
#'   \item{HumanID}{ID from human observer via CPW Photo Warehouse}
#'   \item{ModelID}{ID from MLWIC}
#'   \item{Match}{0 or 1 indicating if MLWIC ID and human ID match}
#'   \item{n}{Number of images in dataset in this group}
#' }
#' 
"id_comp"

#' Logistic Regression Definitions
#'
#' Three minified glm objects for predicting accuracy of MLWIC
#'
#' @name logit
#' @keywords datasets
#' 
NULL

#' @rdname logit
#' 
#' @format \code{logit_c = Match ~ Model Confidence}
#' 
"logit_c"

#' @rdname logit
#' 
#' @format \code{logit_h = Match ~ Model Confidence + Human ID}
#' 
"logit_h"

#' @rdname logit
#' 
#' @format \code{logit_m = Match ~ Model Confidence + Model ID}
#' 
"logit_m"
