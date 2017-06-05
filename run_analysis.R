library(reshape2)

fname <- "dataset.zip"

## Get and unzip dataset:
if (!file.exists(fname)){
  fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fURL, destfile =  fname)
} 
if (!file.exists("UCI HAR Dataset")) { 
  unzip(fname) 
}

# Load labels 
actLab <- read.table("UCI HAR Dataset/activity_labels.txt")
actLab[,2] <- as.character(actLab[,2])

# Load features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract mean and standard deviation
wantedData <- grep(".*mean.*|.*std.*", features[,2])
wantedData.names <- features[wantedData,2]
wantedData.names = gsub('-mean', 'Mean', wantedData.names)
wantedData.names = gsub('-std', 'Std', wantedData.names)
wantedData.names <- gsub('[-()]', '', wantedData.names)


# Load the datasets
getTrain <- read.table("UCI HAR Dataset/train/X_train.txt")[wantedData]
trainY <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
getTrain <- cbind(trainSub, trainY, getTrain)

getTest <- read.table("UCI HAR Dataset/test/X_test.txt")[wantedData]
testY <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
getTest <- cbind(testSub, testY, getTest)

# merge datasets and add labels
allData <- rbind(getTrain, getTest)
colnames(allData) <- c("subject", "activity", wantedData.names)

# factors <- activities & subjects
allData$activity <- factor(allData$activity, levels = actLab[,1], labels = actLab[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)