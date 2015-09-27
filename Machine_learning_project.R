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
#         - Build model - regression (REVIEW REGRESSION VIDEO AGAIN), decision tree (use the 
#           rpart method in the train function), Random Forest (use method="rf" with the train
#           function. Use fancyRPartPlot to create a good looking dendogram. Predict new values 
#           using the predict function.
#         
#         - Cross validation - Essentially the practice of splitting up the data set, using a 
#            training set to build the model and use it on the test set, methods: K-fold? 
#            leave one out? Use the train function to do cross validation.
#         
#         - What expected out of sample error is - The error rate you get on a new data set.
#           Sometimes called generalization error. So the error I'll get in the test set.
#           In sample error is the error we get from the training set. How to calculate:
#           Look at type of errors slides. Can be calculated with mean squared error for
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
#       Random forest is essentially decision tree with bagging.
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
require(rattle)
require(rpart.plot)
require(randomForest)
require(AppliedPredictiveModeling)
##setwd("/Users/brianhudnall/programming/r/machinelearning")


## LOADING DATA

## Uploading the data set and cleaning
training <- read_csv("pml-training.csv")
testing <- read_csv("pml-testing.csv")

## Remove the first columns and other unecessary columns
training <- select(training
                   , -user_name
                   , -cvtd_timestamp
                   , -raw_timestamp_part_1
                   , -raw_timestamp_part_2
                   , -1)
testing <- select(testing
                  , -user_name
                  , -cvtd_timestamp
                  , -raw_timestamp_part_1
                  , -raw_timestamp_part_2
                  , -1)

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
training <- select(training, colNums)

## Explore the dataset
glimpse(training)
summary(training)

## look for any NA values for imputation if needed
## Also look for near zero covariates for removal
sum(is.na(training))

## PARTITION DATA

inTrain <- createDataPartition(y=training$classe,
                               p=0.6, list=FALSE)
training_training <- training[inTrain,]
training_testing <- training[-inTrain,]
dim(training_training)
dim(training_testing)

## PREPROCESSING

## Near Zero Variance Analysis, remove new_window as it has no variance
nzv <- nearZeroVar(training_training, saveMetrics=TRUE)
nzv
training_training <- select(training_training, -new_window)
training_testing <- select(training_testing, -new_window)
testing <- select(testing, -new_window)

## Remove highly correlated predictors. First by calc a correlation matrix
## and then removing values that are highly correlated
descrCor <- cor(training_training[,-54])
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .95)
## There are 19 variables that are correlated higher than 80%
## Remove them from both the training and testing sets
highlyCorDescr <- findCorrelation(descrCor, cutoff = .95)
training_training_filt <- training_training[,-highlyCorDescr]
training_testing_filt <- training_testing[,-highlyCorDescr]
testing_filt <- testing[,-highlyCorDescr]

## SHOW BOXPLOT VIZ

## RUN DATA MODEL - remember to talk about out of sample error
modFit <- rpart(classe ~ ., data=training_training_filt, method="class")
fancyRpartPlot(modFit)

training_testing_predict <- predict(modFit
                                    , training_testing_filt
                                    , type = "class")

confusionMatrix(training_testing_predict
                , training_testing_filt$classe)

training_training_filt$classe <- as.factor(training_training_filt$classe)
training_testing_filt$classe <- as.factor(training_testing_filt$classe)

modFit_rf <- randomForest(classe ~ ., data=training_training_filt)
rf_predictions <- predict(modFit_rf, training_testing_filt, type = "class")
confusionMatrix(rf_predictions, training_testing_filt$classe)

final_predictions <- predict(modFit_rf, testing_filt, type = "class")

## PRINT PREDICTIONS

pml_write_files = function(x){
    n = length(x)
    for(i in 1:n){
        filename = paste0("problem_id_",i,".txt")
        write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
    }
}

pml_write_files(final_predictions)


    