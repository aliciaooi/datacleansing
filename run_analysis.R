Enter file contents hereinstall.packages('dplyr')

library("plyr")

library('dplyr')

library('reshape2')

library('tidyr')

getwd()
setwd('./UCI HAR Dataset')

### NUMBER 1 Combining datasets into one consolidated dataset called All
# Importing data 
          #xtest
           filextest<-'./test/X_test.txt'
           xtest <- read.table(filextest, dec=".", quote="\"", stringsAsFactors=F)
            
           #ytest
            fileytest<-'./test/y_test.txt'
            ytest <- read.table(fileytest, dec=".", quote="\"",stringsAsFactors=F)
            ytest <- rename(ytest, activityid = V1)
            
            #subject test
            filesubtest<-'./test/subject_test.txt'
            subjecttest <- read.table(filesubtest, dec=".", quote="\"",stringsAsFactors=F)
            subjecttest <- rename(subjecttest, subjectid = V1)
      
       ##Combining the test data
            testall<-cbind(subjecttest,ytest, xtest)
           dim(testall) ##2947 563
          
      #subjecttrain
           filesubtrain <-'./train/subject_train.txt'
            subjecttrain <- read.table(filesubtrain, dec=".", quote="\"")
            subjecttrain <- rename(subjecttrain, subjectid = V1)
      #xtrain      
           filextrain <-'./train/X_train.txt'
           xtrain <- read.table(filextrain, dec=".", quote="\"",stringsAsFactors=F)
            
      #ytrain
        fileytrain <-'./train/y_train.txt'
        ytrain <- read.table(fileytrain, dec=".", quote="\"",stringsAsFactors=F)
        ytrain  <- rename(ytrain , activityid = V1)
            
    ## Combine all the training data
          
        trainall<-cbind(subjecttrain, ytrain, xtrain)
        trainall[1:10, 1:10]

    ##Feature
          filefeature  <-'./features.txt'
          feature <- read.table(filefeature, dec=".", quote="\"",stringsAsFactors=F)
          feature   <- rename(feature , measure = V2)
 
    #activity
            fileactivity <-'./activity_labels.txt'
            activity  <- read.table(fileactivity, dec=".", quote="\"",stringsAsFactors=F)
            activity   <- rename(activity , activityid = V1, activityname = V2)


   #Consolidate Data
          #Using rbind to consolidate the test and training data into a dataset called 'All'
          All <- rbind(testall,trainall)
        
##Renaming the dataset with meaningful names as per NUMBER 4 requirement for meaningful variable names 

            names(All) <- c( "subjectid","activityid", feature$measure)

            ## Remove duplicates and getting a clean data set called cleandataset
            
            ##Checking for duplicates within the feature dataset 
            
            #uniquefeature <- unique(feature$measure)
            
            #numduplicates <- length(feature$measure)-length(uniquefeature) ## there are 84 duplicates 
            #There are 84 duplicate names in the dataset

            cleandataset <- All[ ,!duplicated(colnames(All))]

            #OR use UNIQUE cleandataset1 <- All[ ,unique(colnames(All))]
            #dim(cleandataset) ##10299 479
            
            ## Has gone from 10299 563 to 10299 479 without duplicates



      ##NUMBER 2: Getting the subset of dataset of the columns containing names of mean or std

          #Choice 1 : subsetcol <- grepl( "activityid"|"subjectid"|"mean"|"std")" , names(cleandataset) ) ## 81 rows
          #choice 2: subsetcol <- grepl( "[Mm]ean|[Ss]td|activityid|subjectid" , names( cleandataset ) )
          #choice 3: CHOSEN ONE
          ## It makes more sense to take the mean() and std() only as the others seems less relevant
                
                subsetcol <- grepl( "[Mm]ean\\()|[Ss]td\\()|activityid|subjectid" , names( cleandataset ) )
                   
                #To get the subset of mean and std use the index from subsetcol
                                
                cleanmean <- cleandataset[,subsetcol]
                
                #dim(cleanmean) ## 10299 68 columns ie activity, subject and 68 variables 
    
     ##NUMBER 3: Changing the activityid in the cleanmean dataset to activity values and renaming column from 'activityid' to 'activity'

            ## First we will replace the acitivityid in the dataset with actual activity labels from the activity dataset
                
                ## getting list of Activityid from main dataset - row index is  list of activityid from cleanmean
                              
                rowindex <- cleanmean$activityid 
                                                         
                #Matching the activityid in dataset with the activity master table to get the list of activities by names instead of id
                
                activitylist <- activity[rowindex,]
                
                ## Finally replacing the activityID with activityname values in the main dataset cleanamean by referring to the matched list in previous step
                 cleanmean$activityid <- activitylist$activityname
                  
                ##rename activityid to activity columnn in the cleanmean dataset 
                cleanmean <- rename(cleanmean, Activity = activityid)


### NUMBER 5 :Finding average per Subject and Activity
                AverageActivitySubject <- group_by(cleanmean,subjectid,Activity ) %>% summarise_each(funs(mean))
                names(AverageActivitySubject) 
                dim(AverageActivitySubject) 
##Final Cleanup : use the Feature_info.txt to manually add meaning to labels and tidy up formatting and demystifying acronyms- as per NUMBER 4 requirements - labels enduser friendly. 

            #Find and replace variables to make more sense of column names , replace acronyms with end user friendly term
            # use the gsub and pattern matching to replace found 
            
                names(AverageActivitySubject) <- gsub("mean"," Mean",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("std"," Standard Deviation",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("fBody","Frequency Signal ",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Acc","Accelerometer",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("tBody","Time Body Signal ",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Gyro","Gyroscope",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("MeanFreq","Mean Frequency",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("tGravity","Time Gravity signal ",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Jerk"," Jerk",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Mag"," Magnitude",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("X"," for X axial",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Y"," for Y axial",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("Z"," for Z axial",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("[-]", "",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("[()]", "",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("BodyGyroscope", "Body Gyroscope",names(AverageActivitySubject))
                names(AverageActivitySubject)  <- gsub("BodyAccelerometer", "Body Accelerometer",names(AverageActivitySubject))
                
                AverageActivitySubject<- rename(AverageActivitySubject, Subject = subjectid)

                #dim(AverageActivitySubject) ##180 x 68
                ##names(AverageActivitySubject) 
                #AverageActivitySubject[1:10,1:5]
                #AverageActivitySubject[1:10,66:68]

 ##Finally write out to table
      
                write.table(AverageActivitySubject, "./AverageSubjectActivity.txt", row.name=FALSE, col.names = TRUE)

## To read it back into R please use the following statement

                #fileAverage <-'./AverageSubjectActivity.txt'
                #AverageActivitySubject <- read.table(fileAverage , dec=".", quote="\"", stringsAsFactors=F, header= TRUE)

                  #dim(AverageActivitySubject)
                  ## [1] 180  68
