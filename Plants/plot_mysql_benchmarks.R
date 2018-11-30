
my.dat1 <-
  read.table('test-lpidx.txt', sep="\t")

my.dat2 <-
  read.table('test-nridx.txt', sep="\t")

my.dat1[,1:3]
my.dat2[,1:3]



row.names(my.dat1) <- 
  c(" 1 starting",
    " 2 Opening tables",
    " 3 System lock",
    " 4 Table lock",
    " 5 init",
    " 6 optimizing",
    " 7 statistics",
    " 8 preparing",
    " 9 executing",
    "10 Sending data",
    "11 end",
    "12 query end",
    "13 freeing items",
    "14 logging slow query",
    "15 cleaning up"
    )

rownames(my.dat2) <-
  rownames(my.dat1)

matplot(cbind(rowMeans(my.dat1),
              rowMeans(my.dat2)), type='b')

legend(x='topright', inset=0.015,
       legend=c('left-prefix index', '"full" index'),
       pch=c('1','2'), col=c(1,2))

## Difference in mean total execution time
my.dat1 <- rbind(my.dat1, '16 total' = colSums(my.dat1))
my.dat2 <- rbind(my.dat2, '16 total' = colSums(my.dat2))

mean(as.numeric(my.dat1[16,]));sd(as.numeric(my.dat1[16,]))
mean(as.numeric(my.dat2[16,]));sd(as.numeric(my.dat2[16,]))

mean(as.numeric(my.dat1[16,]))-
mean(as.numeric(my.dat2[16,]))

## Difference across all steps:
rbind(rowMeans(my.dat1),
      rowMeans(my.dat2))

plot(c(rowMeans(my.dat1)-rowMeans(my.dat2)))




## Bring in the harder queries

my.dat3 <-
  read.table('test-xxidx.txt', sep="\t")
my.dat4 <-
  read.table('test-xlpidx.txt', sep="\t")

my.dat3 <- rbind(my.dat3, '16 total' = colSums(my.dat3))
my.dat4 <- rbind(my.dat4, '16 total' = colSums(my.dat4))

rownames(my.dat3) <- rownames(my.dat1)
rownames(my.dat4) <- rownames(my.dat1)

matplot(cbind(rowMeans(my.dat1),
              rowMeans(my.dat2),
              rowMeans(my.dat3),
              rowMeans(my.dat4)
              ), type='b',
        xlab="stage", ylab="time/s")

legend(x='topleft', inset=0.015,
       legend=c("q1) 'left-prefix' index", "q2) 'full' index",
         "q3) 'full' index", "q4) failing to use 'full' index"),
       pch=c('1', '2', '3', '4'), col=c(1,2,3,4)
       )

legend(x='bottomleft', inset=0.07,
       title="stages",
       legend=rownames(my.dat1), cex=0.7
       )

