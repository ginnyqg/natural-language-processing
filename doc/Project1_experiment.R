#Spring 2018
#Project 1
#Ginny Gao


packages.used <- c("ggplot2", "plotrix", "waffle", "dplyr", "tibble", "tidyr",  "stringr", "tidytext", "topicmodels", "wordcloud", "plotly", "webshot", "htmlwidgets", "reshape2")

# check packages that need to be installed.
packages.needed <- setdiff(packages.used, intersect(installed.packages()[,1], packages.used))

# install additional packages
if(length(packages.needed) > 0) {
  install.packages(packages.needed, dependencies = TRUE, repos = 'http://cran.us.r-project.org')
}


library(ggplot2)
library(dplyr)
library(tibble)
library(tidyr)
library(stringr)
library(tidytext)
library(topicmodels)
library(wordcloud)
library(plotrix)
library(waffle)
library(plotly)
library(webshot)
library(htmlwidgets)
library(reshape2)


setwd('/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/data')

getwd()
#[1] "/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/data"


spooky <- read.csv('../data/spooky.csv', as.is = TRUE)

head(spooky)

dim(spooky)
#[1] 19579     3

#plot composition of number of texts from 3 authors
num_texts <- table(spooky$author)

num_texts

#  EAP  HPL  MWS 
# 7900 5635 6044


lbls <- paste(names(num_texts), '\n', num_texts, '\n', round(num_texts/sum(num_texts) * 100, 1), '%', sep = '')

#library(plotrix)
pie3D(num_texts, labels = lbls, explode = 0.05, labelcex = 0.8)


#find # of question marks in texts
#library(stringr)

str_count(spooky, '\\?')
#[1]    0 1098    0


#add a num_qns field (number of question marks) for each text
#library(dplyr)
dat1 <- mutate(spooky, num_qns = str_count(spooky$text, '\\?'))


#count of texts with question marks per author
dat2 <- aggregate(dat1$num_qns, by = list(Author = dat1$author), FUN = sum)

dat2

#   Author   x
# 1    EAP 510
# 2    HPL 169
# 3    MWS 419

#library(waffle)
waffle(c('EAP' = dat2[1, 2], 'HPL' = dat2[2, 2], 'MWS' = dat2[3, 2]), rows = 20, size = 0.5, title = 'Count of Questions in Texts by Authors', xlab = '(1 square == 1 question)')

#count of texts with question marks per author per number of question marks
aggregate(dat1$num_qns, by=list(dat1$author, dat1$num_qns), FUN=sum)
#    Group.1 Group.2   x
# 1      EAP       0   0
# 2      HPL       0   0
# 3      MWS       0   0
# 4      EAP       1 423
# 5      HPL       1 159
# 6      MWS       1 384
# 7      EAP       2  60
# 8      HPL       2  10
# 9      MWS       2  32
# 10     EAP       3  15
# 11     MWS       3   3
# 12     EAP       4  12



# #count number of question marks for each author
# dat2 %>% group_by(spooky$author) %>% count(num_qns)
# # A tibble: 12 x 3
# # Groups: spooky$author [3]
#    `spooky$author` num_qns     n
#    <chr>             <int> <int>
#  1 EAP                   0  7439
#  2 EAP                   1   423
#  3 EAP                   2    30
#  4 EAP                   3     5
#  5 EAP                   4     3
#  6 HPL                   0  5471
#  7 HPL                   1   159
#  8 HPL                   2     5
#  9 MWS                   0  5643
# 10 MWS                   1   384
# 11 MWS                   2    16
# 12 MWS                   3     1


# #plot number of texts with question marks per author
# barplot(dat3$x, names = dat3$Group.1)

# #show counts on bar plot
# mtext(at = barplot(dat3$x, names = dat3$Group.1), text = dat3$x)


#plot number of texts with question marks per author
#library(ggplot2)


ggplot(data = dat2, mapping = aes(x = Author, y = x, fill = Author)) + 
    geom_bar(stat="identity") + 
    geom_text(aes(label = x), vjust = - 1) +
    labs(x = 'Author', y = 'Number of questions in texts') +
    theme(panel.background = element_blank())



#sentiment analysis

#library(tidytext)

tidy_text <- unnest_tokens(spooky, word, text)

#spooky_sentiment_bing <- tidy_text %>% inner_join(get_sentiments('bing')) %>% count(word, sentiment) %>% spread(sentiment, n)
#spooky_sentiment_bing


#tidy_text %>% inner_join(get_sentiments('bing'))


tidy_text_sentiment <- tidy_text %>% inner_join(get_sentiments('bing'))
head(tidy_text_sentiment, 100)

#table(tidy_text_sentiment$author, tidy_text_sentiment$sentiment)
     
  #     negative positive
  # EAP     7203     6144
  # HPL     7605     3731
  # MWS     8150     6799


dat3 <- table(tidy_text_sentiment$sentiment, tidy_text_sentiment$author)
dat3

          
  #           EAP  HPL  MWS
  # negative 7203 7605 8150
  # positive 6144 3731 6799


pyramid.plot(dat3[1,c(1:3)], dat3[2,c(1:3)], top.labels = NULL, show.values = TRUE, ndig = 0, main = 'Author by Sentiments', unit = c('Negative', 'Positive'), ppmar = c(4, 4, 4, 4), laxlab = FALSE, raxlab = FALSE)

legend('topright', legend = c("EAP", "HPL", "MWS"), col = c("red", "green", "blue"), lty = 1, bty = 'n', lwd = 8, cex = 0.8, horiz=TRUE)





#what positive and negative words do the authors use?
#comparison cloud

tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("darkgreen", "purple"),
                   max.words = 100)





colnames(dat2)[which(names(dat2) == 'x')] <- 'num_qns'
dat2

#   Author num_qns
# 1    EAP     510
# 2    HPL     169
# 3    MWS     419



dat4 <- as.data.frame.matrix(table(tidy_text_sentiment$author, tidy_text_sentiment$sentiment))
dat4 <- setNames(cbind(rownames(dat4), dat4, row.names = NULL), c('Author', 'negative', 'positive'))
dat4

#   Author negative positive
# 1    EAP     7203     6144
# 2    HPL     7605     3731
# 3    MWS     8150     6799



dat5 <- inner_join(dat2, dat4, by = 'Author')
dat5

#   Author num_qns negative positive
# 1    EAP     510     7203     6144
# 2    HPL     169     7605     3731
# 3    MWS     419     8150     6799


#bubble chart to show sentiments and num_qns by authors
library(plotly)

p <- plot_ly(dat5, x = ~positive, y = ~negative, size = ~num_qns, color = ~Author, 
	type = 'scatter', mode = 'markers', marker = list(opacity = 0.5)) %>% 
    layout(title = '<b>Sentiments and Num of Questions per Author</b>',
    	   xaxis = list(title = '<b>Positive words</b>', showgrid = FALSE),
    	   yaxis = list(title = '<b>Negative words</b>', showgrid = FALSE),
    	   showlegend = FALSE) %>% 
    add_annotations(
            text = paste(dat5$Author, '\n', dat5$num_qns),
            xref = "x",
            yref = "y",
            showarrow = TRUE,
            arrowsize = 0.5,
            ax = 40,
            ay = -60)

p


library(webshot)
library(htmlwidgets)

export(p, file = '/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/figs/Bubble.png')




#compare with sentence length
spooky$sen_length <- str_length(spooky$text)

dat6 <- mutate(spooky, sen_length = spooky$sen_length)

dat7 <- aggregate(dat6$sen_length, by = list(Author = dat6$author), FUN = sum)

dat7

#   Author       x
# 1    EAP 1123585
# 2    HPL  878178
# 3    MWS  916632


colnames(dat7)[which(names(dat7) == 'x')] <- 'sen_length'

dat7

#   Author sen_length
# 1    EAP    1123585
# 2    HPL     878178
# 3    MWS     916632


dat8 <- inner_join(dat7, dat5, by = 'Author')

dat8


#   Author sen_length num_qns negative positive
# 1    EAP    1123585     510     7203     6144
# 2    HPL     878178     169     7605     3731
# 3    MWS     916632     419     8150     6799


#library(reshape2)
new_num_texts <- melt(num_texts)

colnames(new_num_texts) <- c('Author', 'num_text')

new_num_texts

#   Author num_text
# 1    EAP     7900
# 2    HPL     5635
# 3    MWS     6044


dat9 <- inner_join(new_num_texts, dat8, by = 'Author')

dat9

#   Author num_text sen_length num_qns negative positive
# 1    EAP     7900    1123585     510     7203     6144
# 2    HPL     5635     878178     169     7605     3731
# 3    MWS     6044     916632     419     8150     6799




p2 <- plot_ly(dat9, x = ~num_text, y = ~num_qns, size = ~sen_length, color = ~Author, 
	type = 'scatter', mode = 'markers', marker = list(opacity = 0.5)) %>% 
    layout(title = '<b>Num of Texts, Questions, Sentence Length per Author</b>',
    	   xaxis = list(title = '<b>Num of Texts</b>', showgrid = FALSE),
    	   yaxis = list(title = '<b>Num of Questions</b>', showgrid = FALSE),
    	   showlegend = FALSE) %>% 
    add_annotations(
            text = paste(dat9$Author, '\n', prettyNum(dat9$sen_length, big.mark = ',', scientific = FALSE)),
            xref = "x",
            yref = "y",
            showarrow = TRUE,
            arrowsize = 0.5,
            ax = 40,
            ay = -60)


p2

export(p2, file = '/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/figs/Bubble_num_text_qns_sent.png')




# bing_sentiment_counts <- tidy_text %>%
#   inner_join(get_sentiments("bing")) %>%
#   count(word, sentiment, sort = TRUE) %>%
#   ungroup()


# bing_sentiment_counts

# # A tibble: 3,612 x 3
#    word    sentiment     n
#    <chr>   <chr>     <int>
#  1 like    positive    613
#  2 great   positive    512
#  3 well    positive    473
#  4 death   negative    380
#  5 love    positive    331
#  6 strange negative    283
#  7 good    positive    277
#  8 fear    negative    240
#  9 dark    negative    223
# 10 dead    negative    203
# # ... with 3,602 more rows




#n-gram

#bigram in spooky
spooky_bigrams <- spooky %>% unnest_tokens(bigram, text, token = 'ngrams', n = 2)

head(spooky_bigrams, 10)

spooky_bigrams %>% count(bigram, sort = TRUE)

# # A tibble: 221,688 x 2
#    bigram       n
#    <chr>    <int>
#  1 of the    5581
#  2 in the    2743
#  3 to the    1847
#  4 and the   1343
#  5 it was    1037
#  6 from the  1036
#  7 on the    1011
#  8 of a       986
#  9 i had      861
# 10 of my      812
# # ... with 221,678 more rows

#not too interesting, with all the 'stop words'
#separate them, and find more interesting bigrams
bigrams_separated <- spooky_bigrams %>% 
separate(bigram, c('word1', 'word2'), sep = ' ')


#filter out the uninteresting stop words
bigrams_filtered <- bigrams_separated %>%
	filter(!word1 %in% stop_words$word) %>%
	filter(!word2 %in% stop_words$word)


#sort by most common bigrams
bigram_counts <- bigrams_filtered %>%
	count(word1, word2, sort = TRUE)


head(bigram_counts)
# # A tibble: 6 x 3
#   word1  word2           n
#   <chr>  <chr>       <int>
# 1 lord   raymond        27
# 2 fellow creatures      22
# 3 ha     ha             22
# 4 main   compartment    21
# 5 madame lalande        20
# 6 chess  player         18


#unite the 2 words, filter out the stop words, count descendingly

bigrams_united <- bigrams_filtered %>% 
	unite(bigram, word1, word2, sep = ' ')

bigrams_united_counts <- bigrams_united %>% 
	count(bigram, sort = TRUE)

head(bigrams_united_counts, 20)

# # A tibble: 20 x 2
#    bigram               n
#    <chr>            <int>
#  1 lord raymond        27
#  2 fellow creatures    22
#  3 ha ha               22
#  4 main compartment    21
#  5 madame lalande      20
#  6 chess player        18
#  7 short time          18
#  8 heh heh             17
#  9 blue eyes           16
# 10 left arm            16
# 11 shunned house       16
# 12 native country      14
# 13 tempest mountain    14
# 14 brown jenkin        13
# 15 herbert west        13
# 16 tea pot             13
# 17 ten thousand        13
# 18 death's head        12
# 19 human nature        12
# 20 human race          12



#if try trigrams
spooky_trigrams <- spooky %>% unnest_tokens(trigram, text, token = 'ngrams', n = 3) %>% 
	separate(trigram, c('word1', 'word2', 'word3'), sep = ' ') %>% 
	filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
	count(word1, word2, word3, sort = TRUE)



head(spooky_trigrams, 20)

# # A tibble: 20 x 4
#    word1     word2    word3        n
#    <chr>     <chr>    <chr>    <int>
#  1 ha        ha       ha          11
#  2 barrière  du       roule       10
#  3 heh       heh      heh          9
#  4 charles   le       sorcier      8
#  5 ugh       ugh      ugh          8
#  6 mille     mille    mille        7
#  7 rue       des      drômes       6
#  8 arab      abdul    alhazred     4
#  9 automaton chess    player       4
# 10 de        lef      eye          4
# 11 eric      moreland clapham      4
# 12 horned    waning   moon         4
# 13 hu        hu       hu           4
# 14 mad       arab     abdul        4
# 15 miss      bas      bleu         4
# 16 monsieur  le       blanc        4
# 17 moreland  clapham  lee          4
# 18 signora   psyche   zenobia      4
# 19 arch      duchess  ana          3
# 20 bogs      hogs     logs         3




#can find change of sentiments by negation using 'not', 'no'
bigrams_separated %>% filter(word1 %in% c('not', 'no')) %>% count(word1, word2, sort = TRUE)

# # A tibble: 1,621 x 3
#    word1 word2      n
#    <chr> <chr>  <int>
#  1 not   to       139
#  2 not   be       131
#  3 no    longer   113
#  4 no    more     107
#  5 not   the      103
#  6 no    one       88
#  7 not   a         88
#  8 not   have      72
#  9 not   only      66
# 10 no    doubt     60
# # ... with 1,611 more rows


library(igraph)
bigram_counts
bigram_graph <- bigram_counts %>% filter(n > 15) %>% graph_from_data_frame()
bigram_graph


library(ggraph)
set.seed(2018)

ggraph(bigram_graph, layout = "fr") +
   geom_edge_link() +
   geom_node_point(color = "lightblue", size = 5) +
   geom_node_text(aes(label = name), vjust = 1, hjust = 1)










