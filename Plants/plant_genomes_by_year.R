
if(!interactive()){
  postscript("plant_genomes_by_year.ps")
  par(mar=c(3,5,1,1)+0.1)
}

years <-
  read.table("plant_genomes_by_year")

t <- table(years)

plot(t,
     xlab='',
     ylab='Genomes', cex.lab=2)



plot(x=names(t), y=cumsum(table(years)), type='b',
     xlab='',
     ylab='Genomes', cex.lab=2)

plot(x=names(t), y=cumsum(table(years)), type='b', log='y',
     xlab='',
     ylab='Genomes', cex.lab=2)


d <-
  cbind(
    x=as.numeric(names(t)),
    y=log(cumsum(table(years)), 10)
    )

as.data.frame(d)

my.lm <- 
  lm( y~x, data=as.data.frame(d) )

plot(x=names(t), y=cumsum(table(years)), type='b', log='y',
     xlab='',
     ylab='Genomes', cex.lab=2)

abline(my.lm, col=2, lty=2, lwd=2)

px <- 2015
py <-
  my.lm[[1]][1] + px * my.lm[[1]][2]

## ???
py <- 300

plot(x=names(t), y=cumsum(table(years)), type='b', log='y',
     xlim=c(2000, px),
     ylim=c(1, py),
     xlab='',
     ylab='Genomes', cex.lab=2)
abline(my.lm, col=2, lty=2, lwd=2)
