################################# Phase 3 ##################################
# Author: Valerie Wong
# University at Buffalo - CSE 345

#Installing libraries that I may need
install.packages("cld3")
install.packages("textclean")
install.packages("tm")
install.packages("SnowballC")
install.packages("tidytext")
install.packages("wordcloud")
install.packages("rtweet")
install.packages("shiny")
install.packages("topicmodels")

#libraries I plan on using
library(cld3) #For filtering only english tweets
library(textclean) #To help replace emojis in tweet
library(tm) #To get the stop words
library(SnowballC) #To stem words
library(tidytext) #document term matrix
library(syuzhet) #For sentiment analysis
library(wordcloud) #To make a word cloud
library(rtweet) #ts_plot
library(plyr)
library(stringr)
library(ggplot2)
library(dplyr)
library(tidyverse)
# library(shiny)
library(NLP)
library(topicmodels)
library(SnowballC) #For text stemming
library(httr)
library(stm) #structural topic models

#Open the csv file
danold_trump_tweets <- read.csv(file.choose())

#Find all the tweets that are in English and keep those records using cld3 from google
danold_trump_tweets$is_english = detect_language(danold_trump_tweets$tweet) == "en"

# Remove rows where the cleaned tweet is not in English or is hard to detect
danold_trump_tweets <- danold_trump_tweets %>% 
  filter(is_english == TRUE)

#Remove the collected_at column
danold_trump_tweets$collected_at <- NULL

#Cleaning Tweets
danold_trump_tweets$clean_tweet = gsub("&amp", "", danold_trump_tweets$tweet) #Removes &amp for & encoding
danold_trump_tweets$clean_tweet = gsub("&gt", "", danold_trump_tweets$clean_tweet) #Removes &gt for > encoding
danold_trump_tweets$clean_tweet = gsub("&lt", "", danold_trump_tweets$clean_tweet) #Removes &lt for < encoding
danold_trump_tweets$clean_tweet = gsub("http\\S+", "", danold_trump_tweets$clean_tweet) #Removes the t.co link
danold_trump_tweets$clean_tweet = gsub("@\\w+", "", danold_trump_tweets$clean_tweet) #Removes any mentioning

danold_trump_tweets$clean_tweet = gsub("[[:punct:]]", "", danold_trump_tweets$clean_tweet) #Removes punctuation
danold_trump_tweets$clean_tweet = gsub("[[:digit:]]", "", danold_trump_tweets$clean_tweet) #Removes numbers
danold_trump_tweets$clean_tweet = gsub("[ \t]{2,}", "", danold_trump_tweets$clean_tweet) #Removes tabs
danold_trump_tweets$clean_tweet = gsub("^\\s+|\\s+$", "", danold_trump_tweets$clean_tweet) #Removes any white spacing
danold_trump_tweets$clean_tweet = gsub("\\\n", " ", danold_trump_tweets$clean_tweet) #Replace new line characters with a space

#Get the tweet length
danold_trump_tweets$tweet_length <- nchar(danold_trump_tweets$clean_tweet)
max(danold_trump_tweets$tweet_length)

#Replace emojis with known words
danold_trump_tweets$clean_tweet <- replace_emoji(danold_trump_tweets$clean_tweet)
danold_trump_tweets$clean_tweet <- replace_non_ascii(danold_trump_tweets$clean_tweet) #Cleaning the excess <f0> and similar after replacing emojis

#Convert text to lower case
danold_trump_tweets$clean_tweet <- tolower(danold_trump_tweets$clean_tweet)

#Remove stop words from tweet
new_stopwords <- c("trump", stopwords("en"))
danold_trump_tweets$clean_tweet <- removeWords(danold_trump_tweets$clean_tweet, new_stopwords)

#Export dataframe to a csv file so there is no need to go through long wait time of cleaning
write.csv(danold_trump_tweets, "./cleaned_danold_trump_data.csv", row.names=FALSE)

######################################## phase 4 ############################################
cleaned_dt_tweets <- read.csv(file.choose()) #Choose the cleaned csv file

############## Simple Stats #############
summary(cleaned_dt_tweets) #Summary of the entire data frame
summary(cleaned_dt_tweets$clean_tweet) #Summary of only the cleaned tweets
shape(cleaned_dt_tweets)

######### Further cleaning#############

#Remove is_english column and original tweet column
cleaned_dt_tweets$is_english <- NULL
cleaned_dt_tweets$tweet <- NULL

#Clean clean_tweets by stemming words
cleaned_dt_tweets$clean_tweet <- wordStem(cleaned_dt_tweets$clean_tweet, language="en")

#Remove rows where the follower count is below 5
cleaned_dt_tweets <- cleaned_dt_tweets %>% 
  filter(cleaned_dt_tweets$user_followers_count > 5)

#Remove stop words from tweet
new_stopwords2 <- c("live","debate","video","two","saying","electionnight","replublicans","democrats","pennsylvania","florida","anything","tell","republican","democrat","called","put","wont","election", "years","also","yet","already","lets","already","person","lets","president", "house","please","let","uselection","gop","day","americans","electionday","joebiden","elections","doesnt","votes","american","need","today","must","well", "voting", "time", "see", "well", "sure", "youre", "got", "may", "made", "say", "thats", "ever", "done", "electionresults", "state", "usa", "world", "every", "voted", "vot", "next", "isnt", "bidenharri", "many", "country", "joe", "take", "come", "fact", "without", "everyone", "actually", "hope", "thing", "another", "presidential", "really", "elect", "new", "didnt", "much", "keep", "real", "getting", "someone", "give", "way", "trump", "donald", "donaldtrump", "biden", "will", "just", "people", "like", "now", "can", "hes", "even", "right", "think", "know", "one", "trumps", "dont", "get", "still", "want", "back", "bidenharris", "says", "going", "danoldtrump", "cant", "said", "make", "america", "might", "theyre", "since", "gets", "something", "four", "usaelections", "hey", "yes",  stopwords("en"))
cleaned_dt_tweets$clean_tweet <- removeWords(cleaned_dt_tweets$clean_tweet, new_stopwords2)

##########################################
#Final cleaned text - stemmed words and removed stop words
write.csv(cleaned_dt_tweets, "./cleaned_danold_trump_data_stemmed.csv", row.names=FALSE)

# #Keep in global scope the amount of cores
# options(mc.cores = 4)
# tm_parLapply_engine(parallel::mclapply)

#Build corpus
cleaned_dt_tweets <- read.csv(file.choose()) #If you already have the cleaned_danold_trump_stemmed.csv, then start here
corpus <- iconv(cleaned_dt_tweets$clean_tweet)
corpus <- Corpus(VectorSource(corpus))

#Structure the twitter data tweet to be a term document matrix
clean_set <- tm_map(corpus, stripWhitespace) #Cleaning corpus of the white space

#Stem the words
clean_set <- tm_map(clean_set, stemDocument)



############################################
# #Strip the whitespace
# clean_set <- tm_map(corpus, content_transformer(stripWhitespace)) #My computer has 4 cores, makes process faster with parallelization

# #Stem the words
# clean_set <- tm_map(clean_set, content_transformer(stemDocument))

# #Term Document Matrix
tdm <- TermDocumentMatrix(clean_set)

## Document Term Matrix
dtm <- DocumentTermMatrix(clean_set)
head(dtm)

# #EXPERIMENT - VISUALIZATION
# pal <- brewer.pal(8, "Dark2")
# wordcloud(clean_set, max.words=150, random.order=F, col=pal) #Took some time...
##########################################

# 0.99 for sparsity = 89 terms
# 0.991 for sparsity = 105 terms
# 0.995 for sparsity = 327
tdm_removed <- removeSparseTerms(tdm, 0.99)

#Convert the term document matrix to a matrix
w <- as.matrix(tdm_removed)
w <- sort(rowSums(w), decreasing=TRUE)

#Plotting bar plot of term frequency
barplot(w, las=2, col=rainbow(50))

#Word cloud version of term frequency
# set.seed(222) #do i even need this???
wordcloud(words = names(w), freq=w, random.order=F, colors=brewer.pal(8, 'Dark2'))

###################################
###################################
#Sentiment Analysis
# s <- iconv(cleaned_dt_tweets$clean_tweet)
sentiment <- get_nrc_sentiment(tdm_removed[["dimnames"]][[1]])
sentiment2 <- get_nrc_sentiment(tdm_removed_2[["dimnames"]][[1]])

tdm_removed[["dimnames"]][[1]]
sentiment

#bar plot the sentiment
barplot(colSums(sentiment2), las=2, col=rainbow(10), ylab="Count", main="Sentiment around Danold Trump Tweets")
####################################

#Get the top tweets based on likes
top_liked_tweets <- cleaned_dt_tweets %>% 
  arrange(desc(likes))

View(top_liked_tweets)

#Get the top tweets based on retweets
top_retweeted_tweets <- cleaned_dt_tweets %>% 
  arrange(desc(retweet_count))
View(top_retweeted_tweets)

#Get tweets over time plotted
ts_plot(cleaned_dt_tweets, by="day", color="deepskyblue3") +
  labs(x = "Date", y = "Count", title = "What is the frequency of tweets about Donald Trump over time?", 
       subtitle = "Tweets per day frequency")

#Get information about the tweet length about Donald Trump
tweet_length_info <- cleaned_dt_tweets %>% 
  #Get only tweets where tweets are below 281 characters
  filter(tweet_length < 281) %>% 
  ggplot() + 
  aes(y=tweet_length) + 
  geom_boxplot(fill="deepskyblue2") +
  labs(title = "How long tweets are regarding Donald Trump", x="", subtitle="Average tweet length", y="Character number") + 
  coord_flip()

tweet_length_info
  
######################################################
#phase 5 - Topic Modeling on clean_set

# 0.99 for sparsity = 89 terms
# 0.991 for sparsity = 105 terms
# 0.995 for sparsity = 327
dtm_removed <- removeSparseTerms(dtm, 0.99)

#Convert the term document matrix to a matrix
dtm_removed_matrix <- as.matrix(dtm_removed)

#Remove any row where there is not at least one non zero entry
# I.e remove any documents without any words
doc.lengths <- rowSums(dtm_removed_matrix)
dtm_removed_full <- dtm_removed[doc.lengths > 0, ]


# #Choose a k value - minimum is 2 topics
# k_result <- FindTopicsNumber(
#   dtm_removed_full,
#   topics = seq(from = 2, to = 5, by = 1),
#   metrics = c("CaoJuan2009", "Arun2010", "Deveaud2014"),
#   method = "VEM",
#   control = list(seed = 831),
#   mc.cores = 2L,
#   verbose = TRUE)

#dtm_var = 0.99 = 85 terms
# 0.991 = 98
# 0.995 = 320 terms


#For some topics
SEED = sample(1:1000000, 1)

#VEM LDA model
lda_model <- LDA(dtm_removed_full, k=3, control=list(seed=SEED)) #maximum k value should be 3 to make process faster
#VEM FIXED
VEM_FIXED <- LDA(dtm_removed_full, k=3, control=list(estimate.alpha = FALSE, seed=SEED))
#GIBBS
Gibbs <- LDA(dtm_removed_full, k = 3, method="Gibbs", control=list(seed = SEED, burnin = 1000,
                                                                   thin = 100,    iter = 1000))
#CTM - took maybe at least 3 minutes
ctm <- CTM(dtm_removed_full, k = 3, control = list(seed = SEED, var = list(tol = 10^-4), em = list(tol = 10^-3)))


#View all the made models
models <- list(VEM = lda_model, VEM_Fixed = VEM_FIXED, GIBBS = Gibbs, CTM = ctm)
lapply(models, terms, 10) #Top 10 terms from the two topics

#Posterior
topic = 3
words = posterior(Gibbs)$terms[topic, ]
topwords_gibbs = head(sort(words, decreasing = T), n = 50)
topwords
wordcloud(names(topwords_gibbs), topwords_gibbs) #Word cloud plotting the top words proportional to their occurrence of the Gibbs model

#CTM
words_ctm = posterior(CTM)$terms[topic, ]
topwords_ctm = head(sort(words, decreasing = T), n = 50)
wordcloud(names(topwords_ctm), topwords_ctm) #Word cloud plotting the top words proportional to their occurrence of the ctm model

#LDA
words_lda = posterior(lda_model)$terms[topic, ]
topwords_lda = head(sort(words, decreasing = T), n = 50)
wordcloud(names(topwords_lda), topwords_lda) #Word cloud plotting the top words proportional to their occurrence of the ctm model

#VEM_fixed
words_vem_fixed = posterior(VEM_FIXED)$terms[topic, ]
topwords_vem_fixed = head(sort(words_vem_fixed, decreasing = T), n = 50)
wordcloud(names(topwords_vem_fixed), topwords_lda) #Word cloud plotting the top words proportional to their occurrence of the ctm model

topic.docs = posterior(Gibbs)$topics[, topic]
topic.docs = sort(topic.docs, decreasing = T)
topic.docs
