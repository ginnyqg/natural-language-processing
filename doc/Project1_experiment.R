#Spring 2018
#Project 1
#Ginny Gao


packages.used <- c("ggplot2", "plotrix", "waffle", "dplyr", "tibble", "tidyr",  "stringr", "tidytext", "topicmodels", "wordcloud")

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



setwd('/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/data')

getwd()
#[1] "/Users/qinqingao/Documents/GitHub/spring2018-project1-ginnyqg/data"


spooky <- read.csv('../data/spooky.csv', as.is = TRUE)

head(spooky)

dim(spooky)
#[1] 19579     3

#plot composition of number of texts from 3 authors
mytable <- table(spooky$author)

mytable

#  EAP  HPL  MWS 
# 7900 5635 6044


lbls <- paste(names(mytable), '\n', mytable, '\n', round(mytable/sum(mytable) * 100, 1), '%', sep = '')

#library(plotrix)
pie3D(mytable, labels = lbls, explode = 0.05, labelcex = 0.8)


#find # of question marks in texts
#library(stringr)

str_count(spooky, '\\?')
#[1]    0 1098    0


#add a num_qns field (number of question marks) for each text
#library(dplyr)
dat1 <- mutate(spooky, num_qns = str_count(spooky$text, '\\?'))


#count of texts with question marks per author
dat2 <- data.frame(dat1)

dat3 <- aggregate(dat1$num_qns, by = list(Author = dat1$author), FUN=sum)
dat3

#   Author   x
# 1    EAP 510
# 2    HPL 169
# 3    MWS 419

#library(waffle)
waffle(c('EAP' = dat3[1, 2], 'HPL' = dat3[2, 2], 'MWS' = dat3[3, 2]), rows = 20, size = 0.5, title = 'Count of questions in texts for authors', xlab = '(1 square == 1 question)')


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


ggplot(data = dat3, mapping = aes(x = Author, y = x, fill = Author)) + 
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



dat4 <- table(tidy_text_sentiment$sentiment, tidy_text_sentiment$author)
dat4

          
  #           EAP  HPL  MWS
  # negative 7203 7605 8150
  # positive 6144 3731 6799


pyramid.plot(dat4[1,c(1:3)], dat4[2,c(1:3)], top.labels = NULL, show.values = TRUE, ndig = 0, main = 'Author by Sentiments', unit = c('Negative', 'Positive'), ppmar = c(4, 4, 4, 4), laxlab = FALSE, raxlab = FALSE)

legend('topright', legend = c("EAP", "HPL", "MWS"), col = c("red", "green", "blue"), lty = 1, bty = 'n', lwd = 8, cex = 0.8, horiz=TRUE)




























