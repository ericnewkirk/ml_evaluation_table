# ml_evaluation_table

A simple shiny app for evaluating performance of machine learning models in 
 classifying images of wildlife.
 
### Data
~ 250k photos were identified by human observers as
 well as a popular pre-trained machine learning algorithm. The study providing
 the test images closely resembles those used for model training in geographic
 area, habitat, protocol, and suite of species present.

Actual species and image paths have been anonymized as the data from the
 test study remains unpublished. The species in the table were made up on the
 spot as stand-ins for the actual species in the photos, with some attempt
 made to retain similarites in size and taxonomy.

Because the model was trained on a different dataset the IDs don't correspond
 to those used in the test data cleanly. IDs in the test data were combined
 until each ID from the model could be mapped to a single ID in the test data
 for comparison purposes, but in many cases multiple model IDs correspond to a
 single human ID. See the "Bird" category in the table for an example. While
 these photos weren't actually of birds, they represent a related group of
 species and the model IDs presented as birds here correspond to members of
 that group.

Some model IDs represent species not present in the test dataset, so mapping
 them to a correct ID was impossible. These IDs are mostly represented by fish
 species in the anonymized data, because I was tired of trying to come up with
 other farm animals.

### To run:
1. Clone or download the repository from github
2. Open the .Rproj file in RStudio
3. Run `packrat::restore()` in the console - this step only needs to be
performed once, so you can skip it if you open the app again in the future
3. Run `shiny::runApp()` in the console, or open the app.R file in the editor
 and click the Run App button
 