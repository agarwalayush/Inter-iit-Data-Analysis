# LDA Analysis
training_dta  <-Corpus(DirSource("~/Downloads/Inter IIT 3/training"), readerControl=list(reader=readPlain))
testing_dta<- Corpus(DirSource("~/Downloads/Inter IIT 3/test"), readerControl=list(reader=readPlain))
extendedstopwords=c("a","about","above","across","after","MIME", "Version","forwarded","again","against","almost","along","already","always","am","among","an","and","another","any","anybody","anyone","anything","anywhere","are","area","areas","aren't","around","as","ask","asked","asking","asks","at","away","b","back","backed","backing","backs","be","became","because","become","becomes","been","before","began","behind","being","beings","below","best","better","between","but","by","c","came","can","cannot","can't","case","cases","certain","certainly","clear","clearly","come","could","couldn't","d","did","didn't","differ","different","differently","do","does","doesn't","doing","done","don't","down","downed","downing","downs","during","e","each","early","either","end","ended","ending","ends","enough","even","evenly","ever","every","everybody","everyone","everything","everywhere","f","face","faces","fact","facts","far","felt","few","find","finds","first","for","four","from","full","fully","further","furthered","furthering","furthers","g","gave","general","generally","get","gets","give","given","gives","go","going","good","goods","got","great","greater","greatest","group","grouped","grouping","groups","h","had","hadn't","has","hasn't","have","haven't","having","he","he'd","he'll","her","here","here's","hers","herself","he's","high","higher","highest","him","himself","his","how","however","how's","i","i'd","if","i'll","i'm","important","in","interest","interested","interesting","interests","into","is","isn't","it","its","it's","itself","i've","j","just","k","keep","keeps","kind","knew","know","known","knows","l","large","largely","last","later","latest","least","less","let","lets","let's","like","likely","long","longer","longest","m","made","make","making","man","many","may","me","member","members","men","might","more","mr","mrs","much","must","mustn't","my","myself","n","necessary","need","needed","needing","needs","never","new","newer","newest","next","no","nobody","non","noone","nor","not","nothing","now","nowhere","number","numbers","o","of","off","often","old","older","oldest","on","once","one","only","open","opened","opening","opens","or","order","ordered","ordering","orders","other","others","ought","our","ours","ourselves","out","over","own","p","part","parted","parting","parts","per","perhaps","place","places","point","pointed","pointing","points","possible","present","presented","presenting","presents","problem","problems","put","puts","q","quite","r","rather","really","right","room","rooms","s","said","same","saw","say","says","second","seconds","see","seem","seemed","seeming","seems","sees","several","shall","shan't","she","she'd","she'll","she's","should","shouldn't","show","showed","showing","shows","side","sides","since","small","smaller","smallest","so","some","somebody","someone","something","somewhere","state","states","still","such","sure","t","take","taken","than","that","that's","the","their","theirs","them","themselves","then","there","therefore","there's","these","they","they'd","they'll","they're","they've","thing","things","think","thinks","this","those","though","thought","thoughts","three","through","thus","to","today","together","too","took","toward","turn","turned","turning","turns","two","u","under","until","up","upon","us","use","used","uses","v","very","w","want","wanted","wanting","wants","was","wasn't","way","ways","we","we'd","well","we'll","wells","went","were","we're","weren't","we've","what","what's","when","when's","where","where's","whether","which","while","who","whole","whom","who's","whose","why","why's","will","with","within","without","won't","work","worked","working","works","would","wouldn't","x","y","year","years","yes","yet","you","you'd","you'll","young","younger","youngest","your","you're","yours","yourself","yourselves","you've","z")
dtm.control = list(tolower = T,removePunctuation = T, removeNumbers = T,stopwords = c(stopwords("english"),extendedstopwords),stemming = F,wordLengths = c(2,Inf),weighting   = weightTf)
training_dtm = DocumentTermMatrix(training_dta, control=dtm.control)
testing_dtm = DocumentTermMatrix(testing_dta, control=dtm.control)

summary(col_sums(training_dtm))
term_tfidf.training <-tapply(training_dtm$v/row_sums(training_dtm)[training_dtm$i], training_dtm$j, mean) *log2(nDocs(training_dtm)/col_sums(training_dtm > 0))
summary.training = summary(term_tfidf.training)

summary(col_sums(testing_dtm))
term_tfidf.testing <-tapply(testing_dtm$v/row_sums(testing_dtm)[testing_dtm$i], testing_dtm$j, mean) *log2(nDocs(testing_dtm)/col_sums(testing_dtm > 0))
summary.testing = summary(term_tfidf.testing)

training_dtm <- training_dtm[,term_tfidf.training >= 0.90*summary.training["Median"]]
training_dtm <- training_dtm[row_sums(training_dtm) > 0,]
summary(col_sums(training_dtm))
dim(training_dtm)

testing_dtm <- testing_dtm[,term_tfidf.testing >= 0.90*summary.testing["Median"]]
testing_dtm <- testing_dtm[row_sums(testing_dtm) > 0,]
summary(col_sums(testing_dtm))
dim(testing_dtm)

# For No. of Models
best.model <- lapply(seq(2,10, by=1), function(k){LDA(training_dtm, k)})

best.model.logLik <- as.data.frame(as.matrix(lapply(best.model, logLik)))

best.model.logLik.df <- data.frame(topics=c(2:100), LL=as.numeric(as.matrix(best.model.logLik)))

best.model.logLik.df[which.max(best.model.logLik.df$LL),]

# Run on training set.
k <- 5
SEED <- 2010
TM1 <- list(VEM = LDA(training_dtm, k = k, control = list(seed = SEED)),VEM_fixed = LDA(training_dtm, k = k, control = list(estimate.alpha = FALSE, seed = SEED)),Gibbs = LDA(training_dtm, k = k, method = "Gibbs",control = list(seed = SEED, burnin = 1000, thin = 100, iter = 1000)),CTM = CTM(training_dtm, k = k,control = list(seed = SEED,var = list(tol = 10^-4), em = list(tol = 10^-3))))
alphas.train = sapply(TM1[1:2], slot, "alpha")

sapply(TM1, function(x)mean(apply(posterior(x)$topics,1, function(z) - sum(z * log(z)))))

Topic1 <- topics(TM1[["Gibbs"]], 1)
Terms1 <- terms(TM1[["Gibbs"]], 5)
Terms1[,1:5]


test.topics <- posterior(TM1$Gibbs,testing_dtm )
train.topics <- posterior(TM1$Gibbs )


perplexity(object=TM1$VEM)
perplexity(object=TM1$VEM, newdata=testing_dtm)


# Accuracy 
# For 1 star
a1=NULL
a2=NULL
a3 =NULL
a4 =NULL
a5 =NULL
index1= NULL
index2= NULL
index3= NULL
index4= NULL
index5= NULL
test_dim = dim(test.topics$topics)[1]
train_dim = dim(train.topics$topics)[1]

for(i in 1:(test_dim/5)) {
  for (j in 1:(train_dim/5)){
    a1[j]<-sum(abs(test.topics$topics[i, ]-train.topics$topics[j,]))
    a2[j]<-sum(abs(test.topics$topics[i, ]-train.topics$topics[j+3*(train_dim/5),]))
    a3[j]<-sum(abs(test.topics$topics[i, ]-train.topics$topics[j+(train_dim/5),]))
    a4[j]<-sum(abs(test.topics$topics[i, ]-train.topics$topics[j+2*(train_dim/5),]))
    a5[j]<-sum(abs(test.topics$topics[i, ]-train.topics$topics[j+4*(train_dim/5),]))
    
  }
  index1[i]<-sum(a1)/(train_dim/5)
  # print(index1[i])
  index2[i]<-sum(a2)/(train_dim/5)
  index3[i]<-sum(a3)/(train_dim/5)
  index4[i]<-sum(a4)/(train_dim/5)
  index5[i]<-sum(a5)/(train_dim/5)
}
cou1=0
mini1=0
for (k in 1:(test_dim/5)){
  mini1[k]=max(index1[k],index2[k],index3[k],index4[k],index5[k])
  if((mini1[k]==index4[k])||(mini1[k]==index2[k])||(mini1[k]==index3[k])){ 
    cou1=cou1+1
  }
}

a21=NULL
a22=NULL
a23 =NULL
a24 =NULL
a25 =NULL
index21= NULL
index22= NULL
index23= NULL
index24= NULL
index25= NULL

for(i in 1:(test_dim/5)) {
  for (j in 1:(train_dim/5)){
    a21[j]<-sum(abs(test.topics$topics[i+(test_dim/5), ]-train.topics$topics[j,]))
    a22[j]<-sum(abs(test.topics$topics[i+(test_dim/5), ]-train.topics$topics[j+3*(train_dim/5),]))
    a23[j]<-sum(abs(test.topics$topics[i+(test_dim/5), ]-train.topics$topics[j+(train_dim/5),]))
    a24[j]<-sum(abs(test.topics$topics[i+(test_dim/5), ]-train.topics$topics[j+2*(train_dim/5),]))
    a25[j]<-sum(abs(test.topics$topics[i+(test_dim/5), ]-train.topics$topics[j+4*(train_dim/5),]))
    
  }
  index21[i]<-sum(a21)/(train_dim/5)
  index22[i]<-sum(a22)/(train_dim/5)
  index23[i]<-sum(a23)/(train_dim/5)
  index24[i]<-sum(a24)/(train_dim/5)
  index25[i]<-sum(a25)/(train_dim/5)
}

cou2=0
mini2=0
for (k in 1:(test_dim/5)){
  mini2[k]=max(index21[k],index22[k],index23[k],index24[k],index25[k])
  if(((mini2[k]==index21[k])||(mini2[k]==index22[k])||(mini2[k]==index23[k]))){
    cou2=cou2+1
  }
}

# For 3 Star
a31=NULL
a32=NULL
a33 =NULL
a34 =NULL
a35 =NULL
index31= NULL
index32= NULL
index33= NULL
index34= NULL
index35= NULL

for(i in 1:(test_dim/5)) {
  for (j in 1:(train_dim/5)){
    a31[j]<-sum(abs(test.topics$topics[i+2*(test_dim/5), ]-train.topics$topics[j,]))
    a32[j]<-sum(abs(test.topics$topics[i+2*(test_dim/5), ]-train.topics$topics[j+3*(train_dim/5),]))
    a33[j]<-sum(abs(test.topics$topics[i+2*(test_dim/5), ]-train.topics$topics[j+(train_dim/5),]))
    a34[j]<-sum(abs(test.topics$topics[i+2*(test_dim/5), ]-train.topics$topics[j+2*(train_dim/5),]))
    a35[j]<-sum(abs(test.topics$topics[i+2*(test_dim/5), ]-train.topics$topics[j+4*(train_dim/5),]))
    
  }
  index31[i]<-sum(a31)/(train_dim/5)
  index32[i]<-sum(a32)/(train_dim/5)
  index33[i]<-sum(a33)/(train_dim/5)
  index34[i]<-sum(a34)/(train_dim/5)
  index35[i]<-sum(a35)/(train_dim/5)
  
}
cou3=0
mini3=0
for (k in 1:(test_dim/5)){
  mini3[k]=max(index31[k],index32[k],index33[k],index34[k],index35[k])
  if(((mini3[k]==index33[k])||(mini3[k]==index32[k])||(mini3[k]==index34[k]))){
    cou3=cou3+1
  }
}

# For 4 star
a41=NULL
a42=NULL
a43 =NULL
a44 =NULL
a45 =NULL
index41= NULL
index42= NULL
index43= NULL
index44= NULL
index45= NULL


for(i in 1:(test_dim/5)) {
  for (j in 1:(train_dim/5)){
    a41[j]<-sum(abs(test.topics$topics[i+3*(test_dim/5), ]-train.topics$topics[j,]))
    a42[j]<-sum(abs(test.topics$topics[i+3*(test_dim/5), ]-train.topics$topics[j+3*(train_dim/5),]))
    a43[j]<-sum(abs(test.topics$topics[i+3*(test_dim/5), ]-train.topics$topics[j+(train_dim/5),]))
    a44[j]<-sum(abs(test.topics$topics[i+3*(test_dim/5), ]-train.topics$topics[j+2*(train_dim/5),]))
    a45[j]<-sum(abs(test.topics$topics[i+3*(test_dim/5), ]-train.topics$topics[j+4*(train_dim/5),]))
    
  }
  index41[i]<-sum(a41)/(train_dim/5)
  index42[i]<-sum(a42)/(train_dim/5)
  index43[i]<-sum(a43)/(train_dim/5)
  index44[i]<-sum(a44)/(train_dim/5)
  index45[i]<-sum(a45)/(train_dim/5)
  
}
cou4=0
mini4=0
for (k in 1:(test_dim/5)){
  mini4[k]=max(index41[k],index42[k],index43[k],index44[k],index45[k])
  if(((mini4[k]==index42[k])||(mini4[k]==index43[k])||(mini4[k]==index43[k]))){
    cou4=cou4+1
  }
}

# For 5 star
a51=NULL
a52=NULL
a53 =NULL
a54 =NULL
a55 =NULL
index51= NULL
index52= NULL
index53= NULL
index54= NULL
index55= NULL

for(i in 1:(test_dim/5)) {
  for (j in 1:(train_dim/5)){
    a51[j]<-sum(abs(test.topics$topics[i+4*(test_dim/5), ]-train.topics$topics[j,]))
    a52[j]<-sum(abs(test.topics$topics[i+4*(test_dim/5), ]-train.topics$topics[j+3*(train_dim/5),]))
    a53[j]<-sum(abs(test.topics$topics[i+4*(test_dim/5), ]-train.topics$topics[j+(train_dim/5),]))
    a54[j]<-sum(abs(test.topics$topics[i+4*(test_dim/5), ]-train.topics$topics[j+2*(train_dim/5),]))
    a55[j]<-sum(abs(test.topics$topics[i+4*(test_dim/5), ]-train.topics$topics[j+4*(train_dim/5),]))
    
  }
  index51[i]<-sum(a51)/(train_dim/5)
  index52[i]<-sum(a52)/(train_dim/5)
  index53[i]<-sum(a53)/(train_dim/5)
  index54[i]<-sum(a54)/(train_dim/5)
  index55[i]<-sum(a55)/(train_dim/5)
  
}


cou5=0
mini5=0
for (k in 1:(test_dim/5)){
  mini5[k]=max(index51[k],index52[k],index53[k],index54[k],index55[k])
  if(((mini5[k]==index52[k])||(mini5[k]==index53[k])||(mini5[k]==index54[k]))){
    cou5=cou5+1
  }
}
accuracy<- (cou1+cou2+cou3+cou4+cou5)/(test_dim)

# Ranking.R


test= NULL
filelist = list.files(pattern = ".*.txt")

for(i in 1:length(filelist)){
  test[i]<- scan(filelist[i], character(0),sep="\n") # separate each line  
}

for(i in 1:length(test)){
  
  writeLines(test[i], paste("~/Downloads/Casa Vagator/review",i+10000,".txt",sep=""), useBytes = FALSE)
}

for (j in 1: length(filelist)){
  rating_dta[j]<- Corpus(DirSource("~/Downloads/noquote(filelist[j])"), readerControl=list(reader=readPlain))
  extendedstopwords=c("a","about","More","above","across","after","MIME", "Version","forwarded","again","against","almost","along","already","always","am","among","an","and","another","any","anybody","anyone","anything","anywhere","are","area","areas","aren't","around","as","ask","asked","asking","asks","at","away","b","back","backed","backing","backs","be","became","because","become","becomes","been","before","began","behind","being","beings","below","best","better","between","but","by","c","came","can","cannot","can't","case","cases","certain","certainly","clear","clearly","come","could","couldn't","d","did","didn't","differ","different","differently","do","does","doesn't","doing","done","don't","down","downed","downing","downs","during","e","each","early","either","end","ended","ending","ends","enough","even","evenly","ever","every","everybody","everyone","everything","everywhere","f","face","faces","fact","facts","far","felt","few","find","finds","first","for","four","from","full","fully","further","furthered","furthering","furthers","g","gave","general","generally","get","gets","give","given","gives","go","going","good","goods","got","great","greater","greatest","group","grouped","grouping","groups","h","had","hadn't","has","hasn't","have","haven't","having","he","he'd","he'll","her","here","here's","hers","herself","he's","high","higher","highest","him","himself","his","how","however","how's","i","i'd","if","i'll","i'm","important","in","interest","interested","interesting","interests","into","is","isn't","it","its","it's","itself","i've","j","just","k","keep","keeps","kind","knew","know","known","knows","l","large","largely","last","later","latest","least","less","let","lets","let's","like","likely","long","longer","longest","m","made","make","making","man","many","may","me","member","members","men","might","more","mr","mrs","much","must","mustn't","my","myself","n","necessary","need","needed","needing","needs","never","new","newer","newest","next","no","nobody","non","noone","nor","not","nothing","now","nowhere","number","numbers","o","of","off","often","old","older","oldest","on","once","one","only","open","opened","opening","opens","or","order","ordered","ordering","orders","other","others","ought","our","ours","ourselves","out","over","own","p","part","parted","parting","parts","per","perhaps","place","places","point","pointed","pointing","points","possible","present","presented","presenting","presents","problem","problems","put","puts","q","quite","r","rather","really","right","room","rooms","s","said","same","saw","say","says","second","seconds","see","seem","seemed","seeming","seems","sees","several","shall","shan't","she","she'd","she'll","she's","should","shouldn't","show","showed","showing","shows","side","sides","since","small","smaller","smallest","so","some","somebody","someone","something","somewhere","state","states","still","such","sure","t","take","taken","than","that","that's","the","their","theirs","them","themselves","then","there","therefore","there's","these","they","they'd","they'll","they're","they've","thing","things","think","thinks","this","those","though","thought","thoughts","three","through","thus","to","today","together","too","took","toward","turn","turned","turning","turns","two","u","under","until","up","upon","us","use","used","uses","v","very","w","want","wanted","wanting","wants","was","wasn't","way","ways","we","we'd","well","we'll","wells","went","were","we're","weren't","we've","what","what's","when","when's","where","where's","whether","which","while","who","whole","whom","who's","whose","why","why's","will","with","within","without","won't","work","worked","working","works","would","wouldn't","x","y","year","years","yes","yet","you","you'd","you'll","young","younger","youngest","your","you're","yours","yourself","yourselves","you've","z")
  dtm.control = list(tolower = T,removePunctuation = T, removeNumbers = T,stopwords = c(stopwords("english"),extendedstopwords),stemming = F, stripWhitespace=T, wordLengths = c(2,Inf),weighting   = weightTf)
  rating_dtm[j] = DocumentTermMatrix(rating_dta[j], control=dtm.control)
  
  
  
  summary(col_sums(rating_dtm))
  term_tfidf.testing <-tapply(rating_dtm$v/row_sums(rating_dtm)[rating_dtm$i], rating_dtm$j, mean) *log2(nDocs(rating_dtm)/col_sums(rating_dtm > 0))
  summary.testing = summary(term_tfidf.testing)
  
  
  rating_dtm[j] <- rating_dtm[,term_tfidf.testing >= 0.90*summary.testing["Median"]]
  rating_dtm[j] <- rating_dtm[row_sums(rating_dtm) > 0,]
  summary(col_sums(rating_dtm))
  dim(rating_dtm)
  
  # For No. of Models
  #best.model <- lapply(seq(2,10, by=1), function(k){LDA(training_dtm, k)})
  
  #best.model.logLik <- as.data.frame(as.matrix(lapply(best.model, logLik)))
  
  #best.model.logLik.df <- data.frame(topics=c(2:100), LL=as.numeric(as.matrix(best.model.logLik)))
  
  #best.model.logLik.df[which.max(best.model.logLik.df$LL),]
  
  # Run on training set.
  k <- 5
  SEED <- 2010
  TM1 <- list(VEM = LDA(training_dtm, k = k, control = list(seed = SEED)),VEM_fixed = LDA(training_dtm, k = k, control = list(estimate.alpha = FALSE, seed = SEED)),Gibbs = LDA(training_dtm, k = k, method = "Gibbs",control = list(seed = SEED, burnin = 1000, thin = 100, iter = 1000)),CTM = CTM(training_dtm, k = k,control = list(seed = SEED,var = list(tol = 10^-4), em = list(tol = 10^-3))))
  alphas.train = sapply(TM1[1:2], slot, "alpha")
  
  sapply(TM1, function(x)mean(apply(posterior(x)$topics,1, function(z) - sum(z * log(z)))))
  
  Topic1 <- topics(TM1[["Gibbs"]], 1)
  Terms1 <- terms(TM1[["Gibbs"]], 5)
  Terms1[,1:5]
  
  
  rating.topics <- posterior(TM1$Gibbs,rating_dtm )
  #train.topics <- posterior(TM1$Gibbs )
  # Rating of Hotels
  r1=NULL
  r2=NULL
  r3 =NULL
  r4 =NULL
  r5 =NULL
  rating1= NULL
  rating2= NULL
  rating3= NULL
  rating4= NULL
  rating5= NULL
  test_dim = dim(rating.topics$topics)[1]
  train_dim = dim(train.topics$topics)[1]
  
  for(i in 1:(test_dim)) {
    for (j in 1:(train_dim/5)){
      r1[j]<-sum(abs(rating.topics$topics[i, ]-train.topics$topics[j,]))
      r2[j]<-sum(abs(rating.topics$topics[i, ]-train.topics$topics[j+3*(train_dim/5),]))
      r3[j]<-sum(abs(rating.topics$topics[i, ]-train.topics$topics[j+(train_dim/5),]))
      r4[j]<-sum(abs(rating.topics$topics[i, ]-train.topics$topics[j+2*(train_dim/5),]))
      r5[j]<-sum(abs(rating.topics$topics[i, ]-train.topics$topics[j+4*(train_dim/5),]))
      
    }
    rating1[i]<-sum(a1)/(train_dim/5)
    # print(index1[i])
    rating2[i]<-sum(a2)/(train_dim/5)
    rating3[i]<-sum(a3)/(train_dim/5)
    rating4[i]<-sum(a4)/(train_dim/5)
    rating5[i]<-sum(a5)/(train_dim/5)
  }
  cou1=0
  max=0
  positive=0
  negative =0
  for (k in 1:(test_dim)){
    max[k]=max(rating1[k],rating2[k],rating3[k],rating4[k],rating5[k])
    if((max[k]==rating4[k])||(max[k]==rating5[k])||((max[k]==rating3[k]))){
      negative=negative+1
    }
    
  }
  review_index= (test_dim - negative)/(test_dim)
  print(review_index)
  
  
  
  
  
  