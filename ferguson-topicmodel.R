#' ---
#' title: "Ferguson"
#' author: "Shawn Graham"
#' date: "Nov 26 2014"
#' ---
#' 


#' we're assuming that you've already installed the mallet wrapper for R; if not, uncomment and run this line:
#' install.packages('mallet') 

#' if you are using Mavericks OS there could be a problem in installation 

require(mallet)

#' import the documents from the folder
#' each document is here its own text file

documents <- mallet.read.dir("originaldocs/1000chunks/") 
# windows users, remember: have the full path, ie "C:\\mallet-2.0.7\\sample-data\\web\\" and so on throughout this script

mallet.instances <- mallet.import(documents$id, documents$text, "en.txt", token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}")

#' create topic trainer object
n.topics <- 100
topic.model <- MalletLDA(n.topics)

#' load documents
topic.model$loadDocuments(mallet.instances)

## Get the vocabulary, and some statistics about word frequencies.
## These may be useful in further curating the stopword list.
vocabulary <- topic.model$getVocabulary()
word.freqs <- mallet.word.freqs(topic.model)
## Optimize hyperparameters every 20 iterations,
## after 50 burn-in iterations.
topic.model$setAlphaOptimization(20, 50)

## Now train a model. Note that hyperparameter optimization is on, by default.
## We can specify the number of iterations. Here we'll use a large-ish round number.
topic.model$train(200)

## NEW: run through a few iterations where we pick the best topic for each token,
## rather than sampling from the posterior distribution.
topic.model$maximize(10)

#' Get the probability of topics in documents and the probability of words in topics.
#' By default, these functions return raw word counts. Here we want probabilities,
#' so we normalize, and add "smoothing" so that nothing has exactly 0 probability.
doc.topics <- mallet.doc.topics(topic.model, smoothed=T, normalized=T)
topic.words <- mallet.topic.words(topic.model, smoothed=T, normalized=T)  ##adap jockers wordcloud script to use this variable

#' from http://www.cs.princeton.edu/~mimno/R/clustertrees.R
#' transpose and normalize the doc topics
topic.docs <- t(doc.topics)
topic.docs <- topic.docs / rowSums(topic.docs)
write.csv(topic.docs, "ferguson-topics-docs2.csv" ) ## "C:\\Mallet-2.0.7\\topic-docs.csv"

#' Get a vector containing short names for the topics
topics.labels <- rep("", n.topics)
for (topic in 1:n.topics) topics.labels[topic] <- paste(mallet.top.words(topic.model, topic.words[topic,], num.top.words=5)$words, collapse=" ")

#' have a look at keywords for each topic
topics.labels
write.csv(topics.labels, "ferguson-topics-labels2.csv") ## "C:\\Mallet-2.0.7\\topics-labels.csv")

#correlation matrix
# Correlations with significance levels - each 1000 line chunk correlated against the others. Positive correlation - similar topics.
install.packages("Hmisc")
library(Hmisc)
cor.matrix <- cor(topic.docs, use="complete.obs", method="pearson")
write.csv(cor.matrix, "correlation-matrix.csv")
##one could then turn this into a network diagram, for instance, showing which bits of the testimony share similar patterns of discourse, which ones do not.

#' Or we could do word clouds of the topics
library(wordcloud)
for(i in 1:10){
  topic.top.words <- mallet.top.words(topic.model,
                                      topic.words[i,], 10)
  print(wordcloud(topic.top.words$words,
                  topic.top.words$weights,
                  c(4,.8), rot.per=0,
                  random.order=F))
}


## cluster based on shared words
plot(hclust(dist(topic.words)), labels=topics.labels)

#create data.frame
topic_docs <- data.frame(topic.docs)
names(topic_docs) <- documents$id
# Calculate similarity matrix
library(cluster)
topic_df_dist <- as.matrix(daisy(t(topic_docs), metric = "euclidean", stand = TRUE))
# Change row values to zero if less than row minimum plus row standard deviation
# keep only closely related documents and avoid a dense spagetti diagram
# that's difficult to interpret (hat-tip: http://stackoverflow.com/a/16047196/1036500)
topic_df_dist[ sweep(topic_df_dist, 1, (apply(topic_df_dist,1,min) + apply(topic_df_dist,1,sd) )) > 0 ] <- 0

#' Use kmeans to identify groups of similar docs
km <- kmeans(topic_df_dist, n.topics)
# get names for each cluster
simdocs <- vector("list", length = n.topics)
for(i in 1:n.topics){
  simdocs[[i]] <- names(km$cluster[km$cluster == i])
}
