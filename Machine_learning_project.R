## Make sure to site source

## Details of the data set
#     - 6 young health participants perform one set of 10 repitions of unilateral 
#       bicep curls 5 different ways. 
#         - Class A (correct): Exactly to specification
#         - Class B (mistake): Throwing elbows to the front
#         - Class C (mistake): Lifting dumbell halfway
#         - Class D (mistake): Lowering dumbell halfway
#         - Class E (mistake): Thowering the hips to the front

## Goals of the project
#     - Predict the manner in which someone did the exercise ("classe") variable in data set
#     - Can use any variable in the data set to predict
#     - Describe how:
#         - built moded - regression (REVIEW REGRESSION VIDEO AGAIN), decision tree (use the 
#           rpart method in the train function), Random Forest (use method="rf" with the train
#           function. Use fancyRPartPlot to create a good looking dendogram. Predict new values 
#           using the predict function.
#         
#         - cross validation - Essentially the practice of splitting up the data set, using a 
#            training set to build the model and use it on the test set, methods: K-fold? 
#            leave one out? Use the train function to do cross validation.
#         
#         - what expected out of sample error is - The error rate you get on a new data set.
#           Sometimes called generalization error. So the error I'll get in the test set.
#           In sample error is the error we get from the training set. How to calculate:
#           Look at type of errors slides. Can caluclated it with mean squared error for
#           continuous data, or weight false positives
#         
#         - why made choices did
#     - Use prediction model to precist 20 test cases (testing set)

## Submission
#     - Github repo with R markdown and compiled html
#     - Text must be < 2000 and less than 5 figures
#     - Submit a letter score for each test record

## Plan
#     - First explore data set, see what variables are included.
#     
#     - Split the data using createDataPartition, use p=0.75
#     
#     - Do some preprocessing using the preProcess function. This is to figure out
#       what predictor variables to use in the model. This will also allow you to
#       center and scale variables that have large variability. Might have to imput 
#       (method="knnImput") values that are missing.
#     
#     - Create an algorithm using the train function (Decision Tree or random forest)
#       Rnadom forest is essentially decision tree with bagging.
#
#     - Test different algorithms using train and bagging (non-linear models). Potentially
#       boost to enhance week variables.
#     
#     - ConfusionMatrix - take the output from the predict function and pass
#       it to the ConfusionMatrix to see the accuracy
#     
#     - test the algorithm on the test set using the predict function

require(readr)
require(ggplot2)
require(caret)
require(dplyr)
require(stringr)
require(AppliedPredictiveModeling)
setwd(choose.dir())

## Uploading the data set and cleaning
training <- read_csv("pml-training.csv")
testing <- read_csv("pml-testing.csv")

## Remove the first columns
training <- training[,-1]; testing <-testing[,-1]

# if sum of NA by col is less than number of rows than keep it 
testing <- testing[,colSums(is.na(testing)) < nrow(testing)]
testingColNames <- colnames(testing)
## Remove problem_id from the testingColNames set
testingColNames <- testingColNames[-length(testingColNames)]
## add in the classe variable from the training set
testingColNames <- append(testingColNames
                          , names(training)[length(names(training))])
## Find the training columns indexes from the testingColNames
colNums <- match(testingColNames, names(training))
## Filter down the columns based on the values in the training set
training <- training %>% select(colNums)

## Explore the dataset
glimpse(training)
summary(training)

## look for any NA values for imputation if needed
## Also look for near zero covariates for removal
sum(is.na(training))

## Near Zero Variance Analysis, remove new_window as it has no variance
nzv <- nearZeroVar(training, saveMetrics=TRUE)
nzv
training <- select(training, -new_window)

# ## Prinicpal Component analysis -- see which
# ## variables are highly correlated with each 
# ## other
# temp_training <- abs(cor(training[,5:57]))
# ## remove outcomes that are essentially variables correlated with themselves
# diag(temp_training) <- 0 
# which(temp_training > 0.8, arr.ind=T)


# ## trying to vizualize data - may wait on that
# training_col_names <- names(training)
# training_gyros_data <- training %>%
#     select(matches("gyros|classe"))
# transparentTheme(trans = .4)
# featurePlot(x = training_gyros_data[,1:20],
#             y = training_gyros_data$classe,
#             plot = "pairs")

## Do preprocesing - do data transformation need to be made?
## , use createTimeSlices. Read this further: http://topepo.github.io/caret/preprocess.html



    