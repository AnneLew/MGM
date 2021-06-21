# Plot sensitivity global from VM run

library(tidyverse)
library(here)
library(sensitivity)

setwd('../')
wd<-getwd()


load("./sensitivity/output/morris_screen_1mdepths_alpsee_r50.Rdata")
load("./sensitivity/output/morris_screen_1mdepths_alpsee_r100.Rdata")
load("./sensitivity/output/morris_screen_1mdepths_alpsee_r100_1-15.Rdata")
load("./sensitivity/output/morris_screen_1mdepths_alpsee_r100_16-28.Rdata")
load("./sensitivity/output/morris_likelihood.Rdata")


par(mfrow = c(1,1))
plot(morrisOut)
print(morrisOut)

parNames<-morrisOut$factors

## Source https://cran.r-project.org/web/packages/r3PG/vignettes/r3PG-ReferenceManual.html
#summarise the moris output
morrisOut.df <- data.frame(
  parameter = parNames,
  mu.star = apply(abs(morrisOut$ee), 2, mean, na.rm = T),
  sigma = apply(morrisOut$ee, 2, sd, na.rm = T)
) %>%
  arrange( mu.star )

morrisOut.df %>%
  gather(variable, value, -parameter) %>%
  ggplot(aes(reorder(parameter, value), value, fill = variable), color = NA)+
  geom_bar(position = position_dodge(), stat = 'identity') +
  scale_fill_brewer("", labels = c('mu.star' = expression(mu * "*"), 'sigma' = expression(sigma)), palette="Dark2") +
  theme_classic() +
  theme(
    axis.text = element_text(size = 6),
    axis.text.x = element_text(angle=90, hjust=1, vjust = 0.5),
    axis.title = element_blank(),
    legend.position = c(0.05 ,0.95),legend.justification = c(0.05,0.95))
