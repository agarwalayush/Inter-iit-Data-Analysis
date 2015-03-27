library(elmNN)
setwd("D:/Inter IIT Project")
doc=read.table("hotel_ml.txt",header=TRUE, sep=',',stringsAsFactors=FALSE)
doc1=doc[c(-30,-59,-83,-108,-125),]
x=which(complete.cases(doc1)==FALSE)
for(i in x){
  doc1[i-1,c(6:11)]=doc1[i,c(6:11)]}
doc1=doc1[-x,]
y=nrow(doc1)
for(i in c(1:y)){
  doc1[i,2]=gsub('\n','',doc1[i,2])
  doc1[i,1]=i
}
doc1=doc1[-236,]
#distance=read.csv("distance.csv",header=FALSE)
#colnames(distance)='Distance'
#doc2=cbind(doc1,distance)
colnames(doc1)[c(3,5,7)]=c('Rating','Travel','Sleep')
class(doc1[,6])='numeric'
class(doc1[,7])='numeric'
class(doc1[,8])='numeric'
class(doc1[,9])='numeric'
class(doc1[,10])='numeric'
class(doc1[,11])='numeric'

reserve_data=doc1[,c(3,5:11)]

for(i in c(3,5:11)){
  doc1[,i]=(doc1[,i]-min(doc1[,i]))/(max(doc1[,i])-min(doc1[,i]))
}

model = elmtrain(formula= Rating ~ Travel + Location +Sleep +Rooms +Service +Value +Cleanliness, data=doc1[c(1:180),],nhid=5,actfun="sig")
p=predict(model,newdata=doc1)

New_Rating=((p-min(p))/(max(p)-min(p)))*10
doc2=cbind(doc1,round(New_Rating/2,digits=1))
doc2[,c(3,5:11)]=reserve_data
residual=(doc2[,3]-doc2[,12])^2
doc2[,13]=round(residual,digits=1)
print('Training Error')
print(mean(residual[1:180]))
print('Cross Validation Error')
print(mean(residual[181:235]))
doc2[,14]=round(New_Rating,digits=1)
colnames(doc2)[c(12,13,14)]=c('New Rating_0_5','Residuals', 'New Rating')

write.csv(doc2,file="Hotel_ELM.csv",row.names=FALSE)