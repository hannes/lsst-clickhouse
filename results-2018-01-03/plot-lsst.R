library(ggplot2)
library(ggthemes)
library(scales)
library(plyr)

# autoinstall hack
(function(lp) {
r <- "http://cran.rstudio.com/"
np <- lp[!(lp %in% installed.packages()[,"Package"])]
if(length(np)) install.packages(np, repos=r, Ncpus=4)
update.packages(ask=F, oldPkgs=lp, repos=r)
})(c("ggplot2","ggthemes","scales","plyr"))




textsize <- 16
theme <- theme_few(base_size = textsize) + 
theme(axis.text.x = element_text(angle = 90, hjust = 1),
	  legend.title=element_blank(),
	  legend.position=c(0.85,0.08))

compare <- read.table("clickhouse.tsv",sep="\t",na.strings="")
names(compare) <- c ("db","phase","q","rep","time")


levels(compare$db) <- c("Clickhouse")
#compare$db <- ordered(compare$db,levels=c("PostgreSQL","Citusdata","MonetDB"))
levels(compare$q) <- toupper(levels(compare$q))



comparem <- read.table("monetdb.tsv",sep="\t",na.strings="") 
names(comparem) <- c("phase", "q", "time_ms")
levels(comparem$q) <- toupper(levels(comparem$q))
comparem$time <- comparem$time_ms/1000
comparem$rep <- 1
comparem$db <- "MonetDB"
comparem <- comparem[c(6, 1, 2, 5, 4)]

combined <- rbind(compare, comparem)

tpcplot <- function(data,filename="out.pdf",sf=1,phase="hotruns",queries=levels(data$q),width=8,ylimit=100,main="",sub="") {
  pdata <- ddply(data[data$phase==as.character(phase),], c("db", "q"), summarise, avgtime = mean(time), se = sd(time) / sqrt(length(time)) )  
  pdata <- pdata[pdata$q %in% queries,]  
  
  if (nrow(pdata) < 1) {warning("No data, dude."); return(NA)}
  pdata$outlier <- pdata$avgtime > ylimit
  if (nrow(pdata[pdata$outlier,]) > 0) pdata[pdata$outlier,]$se <- NA
  

  pdf(filename,width=width,height=6)
  dodge <- position_dodge(width=.8)
  print(ggplot(pdata,aes(x=q,y=avgtime,fill=db)) + 
    geom_bar(width=.65,position = dodge,stat="identity") + scale_y_continuous(limits = c(0, ylimit),oob=squish) + 
  #  geom_errorbar(aes(ymin=avgtime-se, ymax=avgtime+se), width=0.07,position=dodge) +
    ggtitle(bquote(atop(.(main), atop(.(sub), "")))) + xlab("") + ylab("Duration (seconds)") + 
    scale_fill_manual(values = c("Clickhouse" = "#ffcc00", "MonetDB" = "#2f7ed8")) + 
    theme_few(base_size = textsize) + theme(legend.position="bottom", legend.title=element_blank(), panel.border = element_blank(),axis.line = element_line(colour = "black")) +
    geom_text(aes(label=ifelse(outlier, paste0("^ ",round(avgtime),"s"), ""), hjust=.5,vjust=-.2), position = dodge))
  dev.off()
}


qss <- c("Q04", "Q05", "Q06", "Q07", "Q08", "Q09", "Q10", "Q11", "Q12", "Q13")

tpcplot(data=combined,filename="lsst-hot.pdf",sf="1",phase="hotruns",ylimit=15,main="Query Speed (Hot)",sub="LSST",width=8, queries=qss)




tpcplot(data=combined,filename="lsst-cold.pdf",sf="1",phase="coldruns",ylimit=200,main="Query Speed (Cold)",sub="LSST",width=8, queries=qss)



system("convert -density 300 lsst-hot.pdf -quality 100 lsst-hot.png")
system("convert -density 300 lsst-cold.pdf -quality 100 lsst-cold.png")

