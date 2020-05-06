#importing the dataset 
df <- read.csv("E:/webD/ml/housePrice.csv", header = TRUE)
View(df)
#structure of data
str(df)
#fetching EDD 
summary(df) 
  
  #obs1: To get info of outliers and skewness
  boxplot(df$n_hot_rooms) #presence of outliers
  pairs(~df$Sold+df$rainfall) #presence of outlier
  #obs2: Barplot for suspecious categorical data
  barplot(table(df$airport))
  barplot(table(df$bus_ter)) #1 category, hence useless for analysis
# 1)Rainfall, n_hot_rooms - outliers
# 2)n_hos_beds - missing value
# 3)bus_ter - useless
  
  # Removing outlies by capping and flooring
  
  # 1) for n_hot_room
  quantile(df$n_hot_rooms,0.99)
  uv<-3*quantile(df$n_hot_rooms,0.99) #setting capping limit
  #assign the Uv value to all data above it
  df$n_hot_rooms[df$n_hot_rooms>uv] <- uv
  summary(df$n_hot_rooms) #values are much better than before
  
  # 2) for rainfall
  lv<- 0.3*quantile(df$rainfall,0.01) #setting flooring
  #setting and assigning the value
  df$rainfall[df$rainfall<lv] <- lv
  summary(df$rainfall) #much bettter value
  
  # Treating the missing values
  
  #calculating mean, by removing NA
  mean(df$n_hos_beds, na.rm = TRUE)
  #calculating blank value
  which(is.na(df$n_hos_beds))
  #replacing missing values with mean 
  df$n_hos_beds[is.na(df$n_hos_beds)] <- mean(df$n_hos_beds, na.rm = TRUE)  
  summary(df$n_hos_beds)  
  
  # Variable Transformation 
  
  #creating avg_dis as new variable (for 4 dif. distances)
  df$avg_dist = (df$dist1+df$dist2+df$dist3+df$dist4)/4
  #deleting individual variables (dist1, dist2, dist3, dist4)
  df2 <- df[,-6:-9]  #new dataset without unnecessary columns
  View(df2)
  df=df2 #removed column6 to 9
  rm(df2)
  
  df<-df[,-13] #removed bus_ter as it was useless for analysis

# Dummy Variable Creation     
install.packages("dummies")   
df <- dummy.data.frame(df)
# deleting extra dummy variables
df <- df[,-8]
df <- df[,-13]
summary(df)
View(df) #data ready for analysis

#Logistic Regression with single predictor

glm.fit = glm(Sold~price , data = df, family = binomial)
summary(glm.fit)

#Logistic Regression with multiple predictor

glm.fit = glm(Sold~. , data = df, family = binomial)
summary(glm.fit)

# Predicting Probability
glm.probs = predict(glm.fit, type = "response")
glm.probs[1:10]

#Assigning classes based on boundary value(0.5)
glm.pred = rep("NO",506) #array of 506 values, assigning NO
glm.pred[glm.probs>0.5] = "YES"

#creating confusion matrix
table(glm.pred,df$Sold)

#Linear Discriminant Analysis

lda.fit= lda(Sold~., data = df)
lda.fit
#predictive probabilities
lda.pred = predict(lda.fit, df)
lda.pred$posterior
#assigning class
lda.class = lda.pred$class #0.5 boundary limit
table(lda.class, df$Sold)

sum(lda.pred$posterior[ ,1]>0.8) # columns with boundary 0.8

#Quagratic Discriminant Analysis

qda.fit = qda(Sold~., data = df)
qda.pred = predict(qda.fit, df)
qda.class = qda.pred$class
table(qda.class, df$Sold)


#Test-Train Split
install.packages("caTools")
set.seed(0) #setting a seed
split = sample.split(df,SplitRatio = 0.8)
train_set = subset(df,split == TRUE)
test_set = subset(df, split == FALSE)
  
  #model1: Logistic Regression
  train.fit = glm(Sold~., data= train_set, family = binomial) 
  test.probs = predict(train.fit, test_set, type = 'response')

  test.pred = rep('NO',120) #test_set had 120 obs
  test.pred[test.probs>0.5] = 'YES'

  table(test.pred, test_set$Sold)
  
#K-Nearest Neighbors
trainX = train_set[,-16]
testX = test_set[,-16]
trainY = train_set$Sold
testY = test_set$Sold

k = 3

trainX_s = scale(trainX)
testX_s = scale(testX)

set.seed(0)    #assigning class

knn.pred = knn(trainX_s, testX_s, trainY, k = k)

table(knn.pred,testY)

#Simple Linear Regression
simple_model <- lm(price~room_num, data = df)
summary(simple_model)
plot(df$room_num,df$price)#scatter plot
abline(simple_model) #predicted line

#Multipe Linear Regression
multiple_model <- lm(price~., data = df)
summary(multiple_model)




