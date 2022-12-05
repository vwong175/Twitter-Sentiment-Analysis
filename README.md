# What this project is about

This R project was an experiment into data science from my intro to data science class, EAS 345. For this project, I learned the basics of R, dplyr, and the EDA process. I wanted to challenge myself with conducting data analytics on text, specifically twitter tweets on #DonaldTrump, extracting the most popular words people associated him with and the sentiment with how they thought of him.

## Downloading Dataset

The dataset I used was USA 2020 Political Tweets from [Kaggle](https://www.kaggle.com/datasets/manchunhui/us-election-2020-tweets?resource=download)

## Usage

1. Download one of the csv files in the link specified above and then run the R code choosing the downloaded file. The first part will clean the csv file, "tweets" column and make a new column named "clean_tweet" as well as write a new csv file of the cleaned data. The second portion of this code will plot and graph analytics in regards to the frequency of tweets over time as well as sentiment analysis of the most popular terms used graphed in an ordered bar chart and word cloud.

# Problem Statement

With the ever growing presence of social media, many of us have been using it as a new means of communication, especially in communicating our ideas and thoughts that we may not say in person. A popular example of a social media site would be Twitter, which has amounted to 237 million users.

Twitter is a social media space where users can speak their mind on any topic, topics ranging from music, to pop culture, as well as politics. And with political figures also having their own Twitter accounts, it makes the political social sphere one of the most prominent topics trending on Twitter.

The goal of this project is to analyze the sentiment analysis that Twitter users have on political figures, more specifically, the sentiment analysis of American tweets on the idea of Donald Trump, promptly right before, during and after the 2020 election between him and democratic candidate Joe Biden.

Communicating thoughts and ideas on the internet gives users more freedom in how they express their ideas with great variety in users’ vernacular and communication style. This makes analyzing Twitter users’ ideas more difficult because of the inclusion of special characters, emojis, and unique formatting of words that skew the accuracy of the sentiment analysis on Donald Trump if one were to take a brief look at the words without any preprocessing.

# Collecting Data

The data used in this project was a pre-collected dataset on Kaggle named US Elections 2020 that consisted of two csv files, the hashtag_donaldtrump and the hashtag_joebiden dataset. I decided to use only the hashtag_donaldtrump dataset because both datasets are close to a million scraped tweets and I wanted to focus on one political figure. In the hashtag_donaldtrump dataset, it has 21 columns and 958,580 tweets. From here on, I will refer to the dataset as dt_tweets.

# Cleaning the Data

The raw data extracted from the dataset provided by Kaggle, although extremely informative, still included some difficulties in being practical with sentiment analysis, especially with the tweet column. The tweet column is a character column and is representative of the exact tweet a user made when they tweeted about Donald Trump. However, at the end of each tweet is a link to that specific tweet and that was not necessary for the process of this project. A number of steps were taken to clean the tweet column, the code for which can be found in the sentiment_analysis.r file. The main steps were:

1.  Only consider tweets that were written in English
    
2.  Find the link in a tweet observation and remove it from the tweet
    
3.  For all the English tweets, remove any special characters and extra spacing
    
4.  Remove any numbers and tabs
    
5.  Count the number of characters in the tweet and make a new column with the correct character count
    
6.  Replace all emojis with their respective word associations
    

Due to the long wait time during the cleaning process, the cleaned data was then written to a csv file named cleaned_donald_trump_data.csv.

# Exploratory Data Analysis (EDA)

After collecting and cleaning the tweets column, my main hypothesis before doing any exploratory data analysis was that there would be a great variability in the opinions on Donald Trump. As he was president before during the 2016 election, I hypothesized that a lot of the words used when tweeting about Donald Trump would have extreme language and sentiment. Since Donald Trump was running against Joe Biden, I also had another hypothesis that amongst the words that were tweeted, many people would talk not only about generic political topics like education and reform, but also what was prevalent at the time, which was the Covid-19 pandemic.

## EDA: Frequency of Tweets on Donald Trump over Time

We can see trends of when people start tweeting more about Trump and can correlate an upward trend to specific events during 2020 where people are talking more about Trump. This can also help subset the data as filtering the data to be within a specific time frame and seeing the sentiment around Donald Trump before and after major time events such as the US election night.

## EDA: Top Terms used in Donald Trump Tweets - Bar Graph / Word Cloud

Using the entire cleaned Donald Trump dataset, we can get all of the relevant terms that were used in all of the tweets, observe which words came up most frequently, and what words were used the least. This helps with the sentiment analysis regarding Trump because depending on the word(s), it can be telling of how people see Donald Trump as well as variability and divergence of opinion on Trump.

## EDA: Box Plot on Tweet Length

Seeing how long people are making their tweets about Donald Trump will be telling of how much they have to say about him and whether or not they have a lot or little to say. This helps with further analysis by grouping tweets that are in the third quartile where people are saying more about Trump and seeing what the sentiment is with that. It is also telling of whether or not people are being concise with their opinions or not.

This is used in conjunction with the summary function of the dataframe.


# Modeling and Analysis

For the modeling, I used topic modeling which is about discovering topics in large collections of documents. In the context of this project, a document would be a singular tweet. Topic modeling uses machine learning techniques like LDA, Latent Dirichlet Allocation, and calculating metrics on key term vector space such as text inverse document. However, topic modeling is usually done on documents with a large number of words and because tweets are limited to 280 characters, it would be inaccurate to set the number of topics to look for through the entire corpus to be any high integer value. That is why for the scope of this project, I set the topic number, k, to be three. The modeling portion of this project will use four different models to group the words in the tweet corpus into three topics and see which three topics are prevalent in its machine learning findings.

## Evaluation and Reasoning Behind Models

The purpose of this project is to analyze the sentiment that people have on Donald Trump based on their tweets during the time of the 2020 election period. The four models that I used during this phase were a generic LDA (Latent Dirichlet Allocation), CTM (correlated topic modeling), STM (structural topic models), and Gibbs Sampling. The necessary R package to conduct LDA modeling is `topicmodels` which is used to create the LDA model. If I was working with a smaller dataset, then I would also include the `Idatuning` package which is used to choose the k value, however, due to the large capacity of the dataset of the cleaned Danold Trump tweets even after filtering, it is still quite large and would require a computer with a stronger processor. However, despite this limitation, I know that since I am working with tweets, I know my k value should be an extremely low integer, somewhere between 2-3. Before doing any topic model analysis, any empty documents that exist following preprocessing should be removed, otherwise the topic modeling can’t work.

## LDA

LDA is a generative probabilistic model that is applied to text and extends the probabilistic latent semantic indexing model. It is a mixture model and documents are a mixture of the different topics in the model. In the context of this project, as stated previously, each tweet is a document and thus it makes sense that for each tweet, it is possible there is at least one topic in a tweet. For the LDA model, it includes a bag of words and the ordering of terms in a document/tweet is not important. Documents are exchangeable meaning that the document sequencing is also not important. The probabilistic generative model is intractable so one of the following approximate posterior inference algorithms is used in modeling: Collapsed Gibbs sampling, mean field variational method, and expectation propagation to name a few. For the context of this project I will be using the Gibbs sampling posterior inference algorithm.

The following describes the steps I used as preprocessing to the modeling:

1.  Create a document term matrix named dtm
    
2.  Remove sparse terms with a sparse term removal variable of 0.99, this value is assigned to the variable named dtm_removed
    
3.  Convert the dtm_removed matrix to a real matrix with the as.matrix() function
    
4.  For each document/tweet, count the frequency of all the terms in the document
    
5.  From the document term matrix, remove any document that don’t have any terms in them
    
6.  Set a random seed value from 1 to 1,000,000

## CTM
CTM stands for correlated topic models which is a hierarchical model that explicitly models the correlation of latent topics. It allows for deeper understanding among topics and allows topic proportions to be correlated via the logistic normal distribution. It relaxes the independence assumption approach but creates a more flexible modeling approach than LDA by replacing the Dirichlet distribution with a logistic normal distribution and explicitly incorporating a covariance structure among topics. Essentially, it allows for a more realistic modeling by allowing topics to be correlated.

## STM

STM stands for structural topic models which combine the common topic models to create a semi automated approach to modeling topics. It can incorporate covariates and metadata in the analysis of text and in STM modes that don't include covariates, the modeling approach is akin to the CTM model.

## Gibbs Sampling
The Gibbs sampling model goes through each document and randomly assigns each word in the document to one of the K topics. In my project, since I am working with tweets with already a limited character setting, I made sure that I set the k to a small value which in this case is 3. In doing so, the models are all going to find the top 10 words under the assumption that there are only 3 topics that are spoken of in the text corpus. In the Gibbs sampling, it goes through each word w in the dictionary d, and for each topic t, it computes 2 things: the proportion of words in document d that are currently assigned to topic t and the proportion of assignment to topic t over all documents that come from this word.


# Modeling Conclusions

Because I was working with character data, especially Twitter tweets as the documents, there was a limited amount of information that one can extract because tweets are limited to the 280 character limit. As a Twitter user myself, most users spend one tweet speaking on one topic. As most of the tweets that have already been collected are tweets on Donald Trump, one can argue that is the topic. But to be more specific, the results from the modeling if we stretch the k value, otherwise the number of topics we are looking for to be a value of three.

It can be seen that if we were to categorize the Donald Trump tweets into three categories, in this case, three topics, then one of the main topics is still strictly politically based on his presidency and policies, but as well as an emotional sentiment.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
