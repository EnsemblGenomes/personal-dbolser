
my.dat <-
  read.table("pule")

head(my.dat)
nrow(my.dat)


class(my.dat$V1)

hist(my.dat$V1)

table(cut(my.dat$V1,breaks=10))
table(cut(my.dat$V1,breaks=10))/nrow(my.dat)*100

table(cut(my.dat$V1,breaks=5))
table(cut(my.dat$V1,breaks=5))/nrow(my.dat)*100


table(my.dat$V1>=80)

table(my.dat$V1>=80)/nrow(my.dat)*100
table(my.dat$V1>=90)/nrow(my.dat)*100
