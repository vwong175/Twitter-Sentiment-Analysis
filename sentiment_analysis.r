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
install.packages("waffle")

#libraries I plan on using
library(cld3) #For filtering only english tweets
library(textclean) #To help replace emojis in tweet
library(tm) #To get the stop words
library(SnowballC) #To stem words
library(tidytext) #document term matrix
library(waffle)
library(syuzhet)
library(lubridate)
library(wordcloud) #To make a word cloud
library(base64enc)
library(twitteR)
library(rtweet) #ts_plot
library(ROAuth)
library(devtools)
library(memoise)
library(whisker)
library(rjson)
library(bit64)
library(httr)
library(httpuv)
library(openssl)
library(plyr)
library(stringr)
library(ggplot2)
library(dplyr)
library(tidyverse)

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
cleaned_dt_tweets <- read.csv(file.choose())

#Remove is_english column and original tweet column
cleaned_dt_tweets$is_english <- NULL
cleaned_dt_tweets$tweet <- NULL

#Clean clean_tweets by stemming words
cleaned_dt_tweets$clean_tweet <- wordStem(cleaned_dt_tweets$clean_tweet, language="en")

#Remove rows where the follower count is below 5
cleaned_dt_tweets <- cleaned_dt_tweets %>% 
  filter(cleaned_dt_tweets$user_followers_count > 5)

#Remove stop words from tweet
new_stopwords2 <- c("live","debate","video","two","saying","electionnight","replublicans","democrats","pennsylvania","florida","anything","tell","republican","democrat","called","put","wont","election", "years","also","yet","already","lets","already","person","lets","president", "house","please","let","uselection","gop","day","americans","electionday","joebiden","elections","doesnt","votes","american","need","today","must","well", "voting", "time", "see", "well", "sure", "youre", "got", "may", "made", "say", "thats", "ever", "done", "electionresults", "state", "usa", "world", "every", "voted", "vot", "next", "isnt", "bidenharri", "many", "country", "joe", "take", "come", "fact", "without", "everyone", "actually", "hope", "thing", "another", "presidential", "really", "elect", "new", "didnt", "much", "keep", "real", "getting", "someone", "give", "way", "trump", "donald", "donaldtrump", "biden", "will", "just", "people", "like", "now", "can", "hes", "even", "right", "think", "know", "one", "trumps", "dont", "get", "still", "want", "back", "bidenharris", "says", "going", "danoldtrump", "cant", "said", "make", "america", "vote", stopwords("en"))
cleaned_dt_tweets$clean_tweet <- removeWords(cleaned_dt_tweets$clean_tweet, new_stopwords2)

#Build corpus
corpus <- iconv(cleaned_dt_tweets$clean_tweet)
corpus <- Corpus(VectorSource(corpus))

#Structure the twitter data tweet to be a term document matrix
clean_set <- tm_map(corpus, stripWhitespace) #Cleaning corpus of the white space

# #Term Document Matrix
tdm <- TermDocumentMatrix(clean_set)

# 0.99 for sparsity = 89 terms
# 0.991 for sparsity = 105 terms
# 0.995 for sparsity = 327
tdm_removed <- removeSparseTerms(tdm, 0.991)
tdm_removed

#Convert the term document matrix to a matrix
w <- as.matrix(tdm_removed)
w <- sort(rowSums(w), decreasing=TRUE)

#Plotting bar plot of term frequency
barplot(w, las=2, col=rainbow(50))

#Word cloud version of term frequency
set.seed(222)
wordcloud(words = names(w), freq=w, random.order=F, colors=brewer.pal(8, 'Dark2'))

###################################
#Sentiment Analysis
# s <- iconv(cleaned_dt_tweets$clean_tweet)
sentiment <- get_nrc_sentiment(tdm_removed[["dimnames"]][[1]])

tdm_removed[["dimnames"]][[1]]
sentiment

#bar plot the sentiment
barplot(colSums(sentiment), las=2, col=rainbow(10), ylab="Count", main="Sentiment around Danold Trump Tweets")
####################################

#Get the top 100 tweets based on likes
top_liked_tweets <- cleaned_dt_tweets %>% 
  arrange(desc(likes))

View(top_liked_tweets)

#Get the top tweets based on retweets
top_retweeted_tweets <- cleaned_dt_tweets %>% 
  arrange(desc(retweet_count))
View(top_retweeted_tweets)

#Get tweets over time plotted
ts_plot(cleaned_dt_tweets, by="day", color="deepskyblue3") +
  labs(x = "Date", y = "Count", title = "What is the frequency of my tweets over time?", 
       subtitle = "Tweets per day frequency")

#Get information about the tweet length about Donald Trump
tweet_length_info <- cleaned_dt_tweets %>% 
  #Get only tweets where tweets are below 281 characters
  filter(tweet_length < 281) %>% 
  ggplot() + 
  aes(y=tweet_length) + 
  geom_dotplot(fill="deepskyblue2") +
  labs(title = "How long tweets are regarding Donald Trump", x="", subtitle="Average tweet length", y="Character number") + 
  coord_flip()

tweet_length_info

#Get frequency of tweets over time
tweets_over_time <- ts_plot(cleaned_dt_tweets, by="day", color="deepskyblue3") + 
  labs(x="Date", y="Count", title="Frequency of tweets over time")

tweets_over_time

#Find what device people use
sourcesOfTweets <- cleaned_dt_tweets %>% 
  group_by(source) %>%
  summarize(counting = n()) %>% 
  mutate(source_percentage = round(counting/sum(counting) * 100, 0)) %>%
  arrange(desc(counting))

sourcesOfTweets %>% head(10)

sources_plotting 
  
  




