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















