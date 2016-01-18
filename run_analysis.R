##
# prep
##

# set the working directory to script container
this.dir <- dirname(parent.frame(2)$ofile)
print(paste("Setting working directory to", this.dir))
setwd(this.dir)

# default separator for file paths
buildPath <- function( ..., sep = "/" ) { paste( ..., sep = sep ) }


##
# download source data
##

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
sourceFile <- "sourceData.zip"

if(!file.exists(sourceFile)) {
    print(paste("Downloading source file from", url))
    download.file(url, sourceFile, mode = "wb")
} else {
    print("Source ZIP file already downloaded")
}

print("Unzipping...")
unzip(sourceFile, exdir = ".")

sourceDir <- "UCI HAR Dataset"

if (!dir.exists(sourceDir)) {
    stop("error preparing the source data")
}

print(paste("Unzipped to", sourceDir))


##
# Step 1
# Merge the training and the test sets to create one data set.
##

print("Reading feature values... This may take a while...")
x_testTable <- read.table(buildPath(sourceDir, "test/X_test.txt"))
x_trainTable <- read.table(buildPath(sourceDir, "train/X_train.txt"))
featureValues_Table <- rbind(x_trainTable, x_testTable);

print("Reading activities...")
y_testTable <- read.table(buildPath(sourceDir, "test/y_test.txt"))
y_trainTable <- read.table(buildPath(sourceDir, "train/y_train.txt"))
activities_Table <- rbind(y_trainTable, y_testTable);

print("Reading subjects...")
subject_testTable <- read.table(buildPath(sourceDir, "test/subject_test.txt"))
subject_trainTable <- read.table(buildPath(sourceDir, "train/subject_train.txt"))
subjects_Table <- rbind(subject_trainTable, subject_testTable)

# remove unused variables
rm(x_trainTable, y_trainTable, subject_trainTable, x_testTable, y_testTable, subject_testTable)

print("Reading feature names...")
allFeatures <- read.table(buildPath(sourceDir, "features.txt"))

print("Creating master table...")
masterTable <- cbind(subjects_Table, activities_Table, featureValues_Table)
names(masterTable) <- (c("Subject", "Activity", as.character((allFeatures[, 2]))))

# remove unused variables
rm(subjects_Table,
   featureValues_Table,
   activities_Table,
   allFeatures)


##
# Step 2
# Extract only the measurements on the mean and standard deviation for each measurement.
##

print("Subsetting mean and standard deviation columns...")
requiredFeatures <- grep("-(mean|std)\\(", names(masterTable))
masterTable <- masterTable[, c(1, 2, requiredFeatures)]
rm(requiredFeatures)


##
# Step 3
# Use descriptive activity names to name the activities in the data set
##

print("Labeling activities...")
activityNames <- read.table(buildPath(sourceDir, "activity_labels.txt"))
masterTable[, 2] <- activityNames[masterTable[, 2], 2]


##
# Step 4
# Appropriately label the data set with descriptive variable names.
##

print("Renaming columns with descriptive variable names...")
names(masterTable) <- gsub("^t", "Time_", names(masterTable))
names(masterTable) <- gsub("^f", "Freq_", names(masterTable))
names(masterTable) <- gsub("-mean\\(\\)", "_Mean", names(masterTable))
names(masterTable) <- gsub("-std\\(\\)", "_StdDev", names(masterTable))
names(masterTable) <- gsub("BodyBody", "Body", names(masterTable))
names(masterTable) <- gsub("-", "_", names(masterTable))


##
# Step 5
# From the data set in step 4, create a second,
# independent tidy data set with the average
# of each variable for each activity and each subject.
##

print("Creating a secondary table with column averages per activity and subject...")
avgTable <- aggregate(
    formula = . ~ Activity + Subject,
    data = masterTable,
    FUN = "mean")

# reapply the column order after aggregation
avgTable <- avgTable[, c(2, 1, 3:ncol(avgTable))]

# add '_Mean' to data column names
names(avgTable)[3:ncol(avgTable)] <- paste(names(avgTable)[3:ncol(avgTable)], "_Mean", sep = "")

if (!dir.exists("tidy")) {
    dir.create("tidy")
}

print("Writing output files...")
write.table(masterTable, file = buildPath("tidy", "tidy_all.txt"), row.names = FALSE)
write.table(avgTable, file = buildPath("tidy", "tidy_avg.txt"), row.names = FALSE)
print(paste("Tidy data is in", buildPath(getwd(), "tidy")))

print("Cleaning up...")
unlink(sourceDir, recursive = TRUE)
file.remove(sourceFile)
rm(activityNames, avgTable, masterTable, sourceDir, sourceFile, this.dir, url, buildPath)

print("Done!")



