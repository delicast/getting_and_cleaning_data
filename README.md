# Getting and Cleaning Data
## Coursera final project - David Elizalde

## Introduction: Project Instructions
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
###Review criteria
- The submitted data set is tidy.
- The Github repo contains the required scripts.
- GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
- The README that explains the analysis files is clear and understandable.
- The work submitted for this project is the work of the student who submitted it.

###Getting and Cleaning Data Course Project 
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement.
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names.
1. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## R Script run_analysis.R detailed explanation:

0 - Prepares the libraries and downloads the datasets
```R
library(plyr);

#0.1 Download the Data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Data.zip",method="curl")

#0.2 Unzip the Data and get the files names
unzip(zipfile="./data/Data.zip",exdir="./data")
path_files <- file.path("./data" , "UCI HAR Dataset")

```

1 - Merges the training and the test sets to create one data set.
```R
#1.1 Save data into variables
activity_test  <- read.table(file.path(path_files, "test" , "Y_test.txt" ),header = FALSE)
activity_train <- read.table(file.path(path_files, "train", "Y_train.txt"),header = FALSE)
subject_train <- read.table(file.path(path_files, "train", "subject_train.txt"),header = FALSE)
subject_test  <- read.table(file.path(path_files, "test" , "subject_test.txt"),header = FALSE)
features_test  <- read.table(file.path(path_files, "test" , "X_test.txt" ),header = FALSE)
features_train <- read.table(file.path(path_files, "train", "X_train.txt"),header = FALSE)

#1.2 Merge Test and Train Datasets
#Combine tables
subject_all <- rbind(subject_train, subject_test)
activity_all<- rbind(activity_train, activity_test)
features_all<- rbind(features_train, features_test)

#set names
names(subject_all)<-c("subject")
names(activity_all)<- c("activity")
names_features <- read.table(file.path(path_files, "features.txt"),head=FALSE)
names(features_all)<- names_features$V2

#merge all 3 tables
data_c1 <- cbind(subject_all, activity_all)
data_all <- cbind(features_all, data_c1)
```

2 - Extracts only the measurements on the mean and standard deviation for each measurement.
```R
subset_features_names<-names_features$V2[grep("mean\\(\\)|std\\(\\)", names_features$V2)]
selectedNames<-c(as.character(subset_features_names), "subject", "activity" )
data_all_subset<-subset(data_all,select=selectedNames)
```
3 - Uses descriptive activity names to name the activities in the data set
```R
#Read activity labels and iterate the labels to substitute them for the names in the data_all_subset
activity_labels <- read.table(file.path(path_files, "activity_labels.txt"),header = FALSE)

i=1
for (label in activity_labels$V2) {
    data_all_subset$activity <- gsub(i, label, data_all_subset$activity)
    i <- i + 1
}
```
4-Appropriately labels the data set with descriptive variable names.:
```R
names(data_all_subset)<-gsub("^t", "Time", names(data_all_subset))
names(data_all_subset)<-gsub("^f", "Frequency", names(data_all_subset))
names(data_all_subset)<-gsub("Acc", "Acelerometer", names(data_all_subset))
names(data_all_subset)<-gsub("Gyro", "Gyroscope", names(data_all_subset))
names(data_all_subset)<-gsub("Mag", "Magnitude", names(data_all_subset))
```

5 - From the data set in step 4, creates a second, independent tidy data set with the average 
```R
data_new<-aggregate(. ~subject + activity, data_all_subset, mean)
write.table(data_new, file = "data_new_tidy.txt")
```
