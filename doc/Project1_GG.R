#Spring 2018
#Project 1
#Ginny Gao


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

library(plotrix)
pie3D(mytable, labels = lbls, explode = 0.05, labelcex = 0.8)


#find # of question marks in texts
library(stringr)

str_count(spooky, '\\?')
#[1]    0 1098    0


#add a num_qns field (number of question marks) for each text
library(dplyr)
dat1 <- mutate(spooky, num_qns = str_count(spooky$text, '\\?'))


#count of texts with question marks per author
dat2 <- data.frame(dat1)

dat3 <- aggregate(dat1$num_qns, by = list(Author = dat1$author), FUN=sum)
dat3

#   Author   x
# 1    EAP 510
# 2    HPL 169
# 3    MWS 419


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
library(ggplot2)


ggplot(data = dat3, mapping = aes(x = Author, y = x, fill = Author)) + 
    geom_bar(stat="identity") + 
    geom_text(aes(label = x), vjust = - 1) +
    labs(x = 'Author', y = 'Number of questions in texts') +
    theme(panel.background = element_blank())


















