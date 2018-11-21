
my.dat <-
  read.table("count_interpro_coverage.dat", row.names=1)
head(my.dat)
nrow(my.dat)

rownames(my.dat)

## GO R!
rownames(my.dat) <- 
  sapply(strsplit(rownames(my.dat), '_'),
         function(x){paste(x[1:2], collapse=' ')}
         )
                                       

colnames(my.dat) <-
  c("total.tx",
    "sum.interpro.tx",
    "seg",
    "blastprodom",
    "gene3d",
    "hmmpanther",
    "ncoils",
    "pfam",
    "pfscan",
    "pirsf",
    "prints",
    "scanprosite",
    "signalp",
    "smart",
    "superfamily",
    "tigrfam",
    "tmhmm")

head(my.dat)

plot(my.dat)

barplot(
        t(
          as.matrix(
                    round(my.dat[,3:17]/my.dat[,1]*100)
                    )
          ),
        beside=TRUE
        )

barplot(
        t(
          as.matrix(
                    round(my.dat[,2]/my.dat[,1]*100)
                    )
          ),
        beside=TRUE
        )


plot(hclust(dist(my.dat[,4:17]/my.dat[,1])))

biplot(prcomp(my.dat[,4:17]/my.dat[,1], scale=TRUE))

plot(prcomp(my.dat[,4:17]/my.dat[,1]))

