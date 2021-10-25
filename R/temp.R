human_id_groups <- tibble::tribble(
  ~HumanID, ~NewHumanID, 
  "None", "None/Human/Setup",
  "Human", "None/Human/Setup",
  "Setup Photo", "None/Human/Setup",
  "Black Bear", "Bear",
  "Grizzly Bear", "Bear",
  "Great Horned Owl", "Bird",
  "Bird (non-raptor)", "Bird",
  "Goshawk", "Bird",
  "Grouse", "Bird",
  "Red Squirrel", "Rodent",
  "Flying Squirrel", "Rodent",
  "Mouse", "Rodent",
  "Chipmunk", "Rodent",
  "Ground Squirrel", "Rodent",
  "Uinta Ground Squirrel", "Rodent",
)

model_id_groups <- comp %>% 
  dplyr::filter(Match == 1) %>% 
  dplyr::distinct(ModelID, HumanID) %>% 
  dplyr::left_join(human_id_groups, by = "HumanID") %>% 
  dplyr::mutate(
    NewModelID = dplyr::case_when(
      is.na(NewHumanID) ~ HumanID,
      TRUE ~ NewHumanID
    )
  ) %>% 
  dplyr::distinct(ModelID, NewModelID)

comp2 <- comp %>% 
  dplyr::filter(HumanID != "Unknown", HumanID != "Insect") %>% 
  dplyr::left_join(human_id_groups, by = "HumanID") %>% 
  dplyr::mutate(
    NewHumanID = dplyr::case_when(
      is.na(NewHumanID) ~ HumanID,
      TRUE ~ NewHumanID
    )
  ) %>% 
  dplyr::left_join(model_id_groups, by = "ModelID") %>% 
  dplyr::mutate(
    NewModelID = dplyr::case_when(
      is.na(NewModelID) ~ ModelID,
      TRUE ~ NewModelID
    )
  )

conf_9 <- comp2 %>% 
  dplyr::filter(ModelConfidence >= 0.9)
conf_5 <- comp2 %>% 
  dplyr::filter(ModelConfidence >= 0.5)
  
true_pos <- function(NewHumanID, x) {
  purrr::map_int(
    NewHumanID,
    ~ x %>% 
      dplyr::filter(
        NewHumanID == .x,
        NewModelID == .x
      ) %>% 
      nrow()
  )
}

false_neg <- function(NewHumanID, x) {
  purrr::map_int(
    NewHumanID,
    ~ x %>% 
      dplyr::filter(
        NewHumanID == .x,
        NewModelID != .x
      ) %>% 
      nrow()
  )
}

false_pos <- function(NewHumanID, x) {
  purrr::map_int(
    NewHumanID,
    ~ x %>% 
      dplyr::filter(
        NewHumanID != .x,
        NewModelID == .x
      ) %>% 
      nrow()
  )
}

true_neg <- function(NewHumanID, x) {
  purrr::map_int(
    NewHumanID,
    ~ x %>% 
      dplyr::filter(
        NewHumanID != .x,
        NewModelID != .x
      ) %>% 
      nrow()
  )
}

comp_gr_2 <- comp2 %>% 
  dplyr::count(NewHumanID) %>% 
  dplyr::rename(HumanID = NewHumanID) %>% 
  dplyr::mutate(
    true_pos_all = true_pos(HumanID, comp2),
    true_pos_9 = true_pos(HumanID, conf_9),
    true_pos_5 = true_pos(HumanID, conf_5),
    true_neg_all = true_neg(HumanID, comp2),
    true_neg_9 = true_neg(HumanID, conf_9),
    true_neg_5 = true_neg(HumanID, conf_5),
    false_pos_all = false_pos(HumanID, comp2),
    false_pos_9 = false_pos(HumanID, conf_9),
    false_pos_5 = false_pos(HumanID, conf_5),
    false_neg_all = false_neg(HumanID, comp2),
    false_neg_9 = false_neg(HumanID, conf_9),
    false_neg_5 = false_neg(HumanID, conf_5),
    accuracy_all = (true_pos_all + true_neg_all) / nrow(comp2),
    accuracy_9 = (true_pos_9 + true_neg_9) / nrow(conf_9),
    accuracy_5 = (true_pos_5 + true_neg_5) / nrow(conf_5),
    precision_all = true_pos_all / (true_pos_all + false_pos_all),
    precision_9 = true_pos_9 / (true_pos_9 + false_pos_9),
    precision_5 = true_pos_5 / (true_pos_5 + false_pos_5),
    recall_all = true_pos_all / n,
    recall_9 = true_pos_9 / n,
    recall_5 = true_pos_5 / n
  )

comp_gr_2 %>% 
  reactable::reactable()
MLWIC3::MLWIC3()
# all numbers are off - e.g
# elk in comp: 28780
# elk in comp2: 28347