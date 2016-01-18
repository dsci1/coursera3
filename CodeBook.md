# Code Book

### Source Data

Information about the source variables and the structure of the source data is available in the [source ZIP file](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

### Setup

The `run_analysis.R` script initially sets the working directory to the directory containing the script file. This is done to contain the output within the same directory.

`buildPath` function simplifies generation of file paths by assuming "/" as the default separator.

If it hasn't already been downloaded, the "Human Activity Recognition Using Smartphones Data Set" is downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and saved as `sourceData.zip` in the working directory.

The file is unzipped to "UCI HAR Dataset." This directory is removed at the end of the script. If you need to keep it, comment the line `unlink(sourceDir, recursive = TRUE)`.

The script also removes variables as they become unnecessary. Comment the appropriate `rm()` lines if you need to keep some variables.




### Merge the training and the test sets to create one data set

Test and training data are read from the unzipped files and merged via `rbind`.

`featureValues_Table` contains the monitored values.
`activities_Table` contains the IDs of activities corresponding to each row in `featureValues_Table`.
`subjects_Table` contains the IDs of subjects (humans whose activities were monitored) corresponding to each row in `featureValues_Table`.

Names of each monitored value are read from the `features.txt` file.

All three tables are merged by `cbind` and column names are applied, to produce the `masterTable` containing the complete merged data set.


### Extract only the measurements on the mean and standard deviation for each measurement

`mergeTable` is subset to contain the 'Subject' and 'Activity' columns, and columns containing mean and standard deviation values only.


### Use descriptive activity names to name the activities in the data set

`Activity` column numeric values are replaced with friendly activity names, based on the ID/name combinations in the `activity_labels.txt` file.


### Appropriately label the data set with descriptive variable names

Columns in `masterTable` are renamed with more readable versions.


### From the data set above, create a second, independent tidy data set with the average of each variable for each activity and each subject

A new table, `avgTable`, is created with the help of the `aggregate` function. Columns starting with 3rd are suffixed with "_Mean".

The `masterTable` data is written to file `tidy/tidy_all.txt` in space-delimited format.

The `avgTable` data is written to file `tidy/tidy_avg.txt` in space-delimited format.




