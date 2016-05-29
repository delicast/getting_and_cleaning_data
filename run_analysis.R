######################################################
#     Project - Getting and Cleaning Data            #         
######################################################
######################################################

##################################################
#0 -Library and data download
##################################################
library(plyr);

#0.1 Download the Data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Data.zip",method="curl")

#0.2 Unzip the Data and get the files names
unzip(zipfile="./data/Data.zip",exdir="./data")
path_files <- file.path("./data" , "UCI HAR Dataset")

##################################################
#1 -Merges the training and the test sets to create one data set.
##################################################

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


##################################################
#2 -Extracts only the measurements on the mean and standard deviation for each measurement.
##################################################
subset_features_names<-names_features$V2[grep("mean\\(\\)|std\\(\\)", names_features$V2)]
selectedNames<-c(as.character(subset_features_names), "subject", "activity" )
data_all_subset<-subset(data_all,select=selectedNames)


##################################################
#3 - Uses descriptive activity names to name the activities in the data set
##################################################

#Read activity labels and iterate the labels to substitute them for the names in the data_all_subset
activity_labels <- read.table(file.path(path_files, "activity_labels.txt"),header = FALSE)

i=1
for (label in activity_labels$V2) {
    data_all_subset$activity <- gsub(i, label, data_all_subset$activity)
    i <- i + 1
}

##################################################
#4-Appropriately labels the data set with descriptive variable names.:
##################################################

names(data_all_subset)<-gsub("^t", "Time", names(data_all_subset))
names(data_all_subset)<-gsub("^f", "Frequency", names(data_all_subset))
names(data_all_subset)<-gsub("Acc", "Acelerometer", names(data_all_subset))
names(data_all_subset)<-gsub("Gyro", "Gyroscope", names(data_all_subset))
names(data_all_subset)<-gsub("Mag", "Magnitude", names(data_all_subset))

##################################################
#5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##################################################

data_new<-aggregate(. ~subject + activity, data_all_subset, mean)
write.table(data_new, file = "data_new_tidy.txt")