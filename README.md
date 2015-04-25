##README
###STEP 1: Download the zip file and unzip to the default working directory either manually  or using the script below:
        This will not form part of the run_analysis.R script
        URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
          zipped <- "getdata-projectfiles-UCI HAR Dataset.zip"
          destdir <- "UCI HAR Dataset"
          download.file(URL, destfile=zipped)
          unzip(zipped)

###STEP 2: Run the run_analysis.R script 
        Install packages if required: 
			install.packages('dplyr')
			library("plyr")
			library('dplyr')
			library('reshape2')
			library('tidyr')
			getwd()
			setwd('./UCI HAR Dataset')

#### NUMBER 1 COMBINING DATASETS INTO ONE CONSOLIDATED DATASET CALLED ALL

	1. Importing data 
			#xtest
         	filextest<-'./test/X_test.txt'
			xtest <- read.table(filextest, dec=".", quote="\"", stringsAsFactors=F)
			#ytest     
          
			fileytest<-'./test/y_test.txt'
			ytest <- read.table(fileytest, dec=".", quote="\"",stringsAsFactors=F)
            ytest <- rename(ytest, activityid = V1)
            
    	   #subject_test - importing as Character rather than factor
           filesubtest<-'./test/subject_test.txt'
		   subjecttest <- read.table(filesubtest, dec=".", quote="\"",stringsAsFactors=F)
		   subjecttest <- rename(subjecttest, subjectid = V1)
      
     2.Combining the test data , use the cbind clause to combine the 3 test datasets
          testall<-cbind(subjecttest,ytest, xtest)
					#dim(testall) #2947 563
					  
	 3. Import Training datasets and rename columns to work with more easily
      
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
            
      4.Combine all the training data using cbind again to combine all 3 training datasets
          
           trainall<-cbind(subjecttrain, ytrain, xtrain)
		   #dim(trainall) #7352 563
			
			
      5. Next import the last 2 feature and activity files into  feature and activity datasets  respectively and rename              columns
        
        	#Feature
          	filefeature  <-'./features.txt'
			feature <- read.table(filefeature, dec=".", quote="\"",stringsAsFactors=F)
			feature   <- rename(feature , measure = V2)
 
            #activity
            fileactivity <-'./activity_labels.txt'
            activity  <- read.table(fileactivity, dec=".", quote="\"",stringsAsFactors=F)
            activity   <- rename(activity , activityid = V1, activityname = V2)

        6. CONSOLIDATE TEST AND TRAINING DATA
                
    		 Using rbind , consolidate the test and training data into a dataset called 'All'
          
            All <- rbind(testall,trainall)
											
	      				#dim(All) 10299 563
						 #All[1:10, 1:10]


  		7. Renaming the dataset with meaningful names as per *** NUMBER 4 *** requirement for meaningful variable names 

	    		names(All) <- c( "subjectid","activityid", feature$measure)

		    	All[1:10,1:5] # example of output is as below: 
			    subjectid activityid tBodyAcc-mean()-X tBodyAcc-mean()-Y tBodyAcc-mean()-Z
				1         2          5         0.2571778       -0.02328523       -0.01465376
				2         2          5         0.2860267       -0.01316336       -0.11908252
				3         2          5         0.2754848       -0.02605042       -0.11815167
				4         2          5         0.2702982       -0.03261387       -0.11752018
				5         2          5         0.2748330       -0.02784779       -0.12952716	
		 
					dim(All) #  10299 563
		 		At this point the consolidated dataset All has 10299 rows and 563 columns				
							
           			
		8.  Remove duplicates and getting a clean data set called cleandataset
            
		 Checking for duplicates within the feature dataset by running:
	   	   numduplicates <- length(feature$measure)-length(uniquefeature) ## There are 84 duplicates 
           
		9. There are 84 duplicate names in the dataset therefore to remove duplicates
		 run the following and output to cleandataset which has no duplicates

			  cleandataset <- All[ ,!duplicated(colnames(All))]
			
		Or alternatively UNIQUE clause, cleandataset1 <- All[ ,unique(colnames(All))] to clean the data
			                      
							
		After removing duplicates, dataset has gone from 10299 563 with duplicates to 10299 479 without duplicates                  The output is to 'cleandataset'
					#dim(cleandataset) ##10299 479		


#### NUMBER 2: GETTING THE SUBSET OF DATASET OF THE COLUMNS CONTAINING NAMES "MEAN()" OR "STD()"

	Here we have a few choices : 
		
	Choice 1: Pick all features with mean or std MeanFrequency and GravityMean :  81 measures
				
	        #subsetcol <- grepl( "activityid"|"subjectid"|"mean"|"std")" , names(cleandataset) ) ## 81 measures
			  
	Choice 2: Ignore cases and just take mean and std (both upper and lower case) : 88 measures 
	(86 meatures , activity and subject columns)
		                          
		#subsetcol <- grepl( "[Mm]ean|[Ss]td|activityid|subjectid" , names( cleandataset ) )
				
	**Choice 3 : Only choose the explicit mean() and std() (leaving out the MeanFrequency and GravityMean) 
	with this Choice it outputs only 66 feature/measures.  
	***Note we only get the mean() and std() of measuresments rather than MeanFrequency and GravityMean 
        The assignment was not clear as which mean but looking at data seems Choice 3 is best suited 
  
  
  *** I CHOSE CHOICE 3  *** 
  	This seems more logical, consistent and more  relevant to our exercise:  66 mean/std columns

		subsetcol <- grepl( "[Mm]ean\\()|[Ss]td\\()|activityid|subjectid" , names( cleandataset ) )

  		#To get the subset of mean and std use the index from subsetcol output subset to 'cleanmean' dataset
                
      		cleanmean <- cleandataset[,subsetcol]
                                
		#dim(cleanmean) ## 10299 68 columns ie activity, subject and 66 variables 
	    
                 
At this point, the dimension is 10299 rows and 68 feature variables in an output called cleanmean dataset

### NUMBER 3: CHANGING THE ACTIVITYID VALUES TO ACTIVITY NAMES VALUES AND RENAMING COLUMN
    
    This step involves replacing activityid values in main dataset with the activity names from activity dataset
    
     Replace the activityid in the dataset with actual activity labels from the activity dataset
                
   	names(activity)
         
	Step 1. Getting list of Activityid from main dataset - row index is  list of activityid from cleanmean
               rowindex <- cleanmean$activityid 
                
	Step 2.Matching the activityid in dataset with the activity datset 
	This is a data mapping exercise so we get an activitylist of data which is mapped:
                
                activitylist <- activity[rowindex,]
                			
	This intermediate step gives us a data mapping of the activityid to activityname called activitylist 
	This contains translation of activityid to activitynames we can use to populate the main dataset. 
	Output of activitylist:
						
		  #head(activitylist, 5) 
	      		activityid activityname
         	        	5.0    	 5     STANDING
			5.1      5     STANDING
			5.2      5     STANDING
			5.3      5     STANDING
			5.4      5     STANDING
              
        Step 3. Finally replacing the activityID with activityname values in the main dataset cleanamean by referring to             the matched list in previous step
        We use out translation dataset called activitylist to replace activityid with activityname
				
                  cleanmean$activityid <- activitylist$activityname
          
      	At this point the activity in dataset is now activity names rather than id 
				
	As such all is left is changing renaming column name 'activityid' to 'activity'  in the cleanmean dataset 
	to reflect the  newly replaced activity values
                
                  cleanmean <- rename(cleanmean, Activity = activityid)


	  names(cleanmean) 

	   [1] "Activity"  "subjectid"   "tBodyAcc-mean()-X"   "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z"        
		
	   To look at data : cleanmean[1:5,1:5] ; ouput as follows
				  subjectid Activity tBodyAcc-mean()-X tBodyAcc-mean()-Y tBodyAcc-mean()-Z
				1         2 STANDING         0.2571778       -0.02328523       -0.01465376
				2         2 STANDING         0.2860267       -0.01316336       -0.11908252
				3         2 STANDING         0.2754848       -0.02605042       -0.11815167
				4         2 STANDING         0.2702982       -0.03261387       -0.11752018
				5         2 STANDING         0.2748330       -0.02784779       -0.12952716
			
	At this point, the Activity values are now by labels 
	Columns names are logical and only for mean() and std() in the cleanmean dataset
       During the final cleanup, there will be more formatting and additional labelling for enduser readability

#### NUMBER 5 :FINDING AVERAGE PER SUBJECT AND ACTIVITY USING THE WIDE DATASET FORMAT

	To find average can be done in either wide or melted into long format
	This dataset will be left in Wide dataset format 
          
                AverageActivitySubject <- group_by(cleanmean,subjectid,Activity ) %>% summarise_each(funs(mean))
                names(AverageActivitySubject) 
                dim(AverageActivitySubject) 

  
	It is possible to use the melt into long method which yields exactly the same result then averaging it but opted to 		use wide method
	dim(AverageActivitySubject)
     			     [1] 180  68
	The result is 30 subjects x 6 activities (180) by 68 mean and std columns we chose to subset earlier				 


#### NUMBER 4: Final Cleanup : This is an extension of NUMBER 4 requirements and optional

	Requirements for NUMBER 4 were mostly already completed in earlier steps to produce cleandata dataset. 
	In addition, use the Feature_info.txt to manually add meaning to labels and tidy up formatting 
	extending the NUMBER 4 requirements - making labels enduser friendly, looking at case sensitivity

	Find and replace variables to make more sense of column names , replace acronyms with end user friendly terms

	Also renamed subjectid to Subject to make it consistent with the other column names 

	Use the gsub and pattern matching to find and replace , example the following: 
            
           - firstly replace mean() with 'Mean' and std() with 'Standard deviation'
            
            - then replace ""fbody"" with 'frequency of signal for '
            - replace XYZ with ' 3-axial signals' 
            -rename Acc to Accelerometer 
            
            Also removing some special characters for readability

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
            names(AverageActivitySubject)  <- gsub("BodyAccelerometer", "Body Accelerometer",names(AverageActivitySubject                                                     ))
                
        	AverageActivitySubject<- rename(AverageActivitySubject, Subject = subjectid)

                dim(AverageActivitySubject) ##180 x 68
                

                ##names(AverageActivitySubject) 
                #AverageActivitySubject[1:10,1:5]
                #AverageActivitySubject[1:10,66:68]

#### Finally write out to table
      
        write.table(AverageActivitySubject, "./AverageSubjectActivity.txt", row.name=FALSE, col.names = TRUE)

#### To read it back into R please use the following statement

		fileAverage <-'./AverageSubjectActivity.txt'
		AverageActivitySubject <- read.table(fileAverage , dec=".", quote="\"", stringsAsFactors=F, header= TRUE)

	
