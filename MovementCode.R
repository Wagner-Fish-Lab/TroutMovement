############ Measuring movements distances from telemetry GPS data ###########

library(riverdist)
library(sp)
library(rgdal)


###############################################################################
###############################################################################
###############################################################################


  # 1- Read in stream network. 
  # 2- Read in fish GPS data and snap to stream network
  # 3- Measure movement distances between GPS points for unique fish IDs

###############################################################################
###############################################################################
###############################################################################

# Quick check of stream shapefile to ensure it loads properly 

#streams<-readOGR(".", "streamsM")
#plot(streams)

############################################################################### 
###########################   1   #############################################

#Load in stream shapefile. Shapefile should already have a defined projection. 
streams<-line2network(path=".", layer="streamsM", tolerance=100)
plot(streams)

# Clean stream file by dissolving segments and removing small side streams of no interest. 
# Insert vertices every 1m to increase precision
# Save workspace immediately after to preserve vertices
streams<-cleanup(streams)
save.image("~/ArcGIS/Telemetry/RCode/MovementCode.R.RData")

#topologydots(rivers=streams) #check to make sure flows lines are connected (green connected end points, red disconnected)



############################################################################### 
###########################   2   #############################################


#Read in csv file of fish deteections with with columns for x,y coordinates

fish<-read.csv("May17.csv")
fish <- subset(fish,Fish_ID > 1) #Remove instances where there is no Fish ID
fish$Fish_ID<-as.factor(fish$Fish_ID) 
fish$Date<-as.Date(fish$Date, format="%m/%d/%Y")
fish$sort<-1:nrow(fish) #provide unique ID for each entry


#Assign each detection a segment and vertex based on the detection's lat/lon
fish_riv <- xy2segvert(x=fish$Lat, y=fish$Lon, rivers=streams) 
head(fish_riv)
#hist(fish_riv$snapdist, main="snapping distance (m)") #Check snapping distance for points to streams


fish_riv$sort<-1:nrow(fish_riv) #provide unique ID for each entry
fishm<-merge(fish, fish_riv,by="sort") #merge segments and vertices to original fish file

#Plot points original lat/long and snapped segment/vertex 
points(fish$Lat, fish$Lon, pch=16, col="red")
riverpoints(seg=fish_riv$seg, vert=fish_riv$vert, rivers=streams, pch=15, col="blue")


############################################################################### 
###########################   3   #############################################

##    To measure distance between two points, enter vertex and segment for each
#riverdistance(startseg=35, startvert=53, endseg=16, endvert=4, rivers=streams, map=TRUE)

##    Measure distanced moved for all fish for all dates
##    Not useful unless all fish were detected on the same dates, otherwise it has missing data
#distances<-riverdistanceseq(unique=fishm$Fish_ID, survey=fishm$Date,seg=fishm$seg, vert=fishm$vert, rivers=streams)
#distances

##    Measures distances moved for a single fish for all sample dates (full=TRUE) or only dates fish was detected (full=FALSE)
##    Distances are cummulative and do not account for upstream and downstream    
distances1<-riverdistancematbysurvey(indiv=4816, unique=fishm$Fish_ID, survey=fishm$Date,
            seg=fishm$seg, vert=fishm$vert, rivers=streams, full=FALSE)
distances1


##    Measures distances moved for a single fish for all sample dates (full=TRUE) or only dates fish was detected (full=FALSE)
##    Distances account for upstream and downstream. 
##    net=TRUE for net movement, net=FALSE for total distance
#Calculate distanced moved for a single fish for all sample dates accounting for up and downstream movements
distances2<-upstreammatbysurvey(indiv=4816, unique=fishm$Fish_ID, survey=fishm$Date, 
            seg=fishm$seg, vert=fishm$vert, rivers=streams, full=FALSE, flowconnected=TRUE,net=TRUE)
distances2

##    A TRUE/FALSE table for up/downstream movements
#distances4<-riverdirectionmatbysurvey(indiv=38, unique=fishm$ID, survey=fishm$Date,
            #seg=fishm$seg, vert=fishm$vert, rivers=streams1, full=FALSE,flowconnected=TRUE)


