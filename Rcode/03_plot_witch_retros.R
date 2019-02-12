# plot_witch_retros.R
# make some summary and comparison plots for the base run and 3 catch multiplier runs with no retro

library("ggplot2")
library("dplyr")

res <- read.csv(".\\witch\\witch_retro_res.csv")

bestres <- res %>%
  mutate(absrho = abs(SSBrho)) %>%
  group_by(ChangeYear) %>%
  filter(absrho == min(absrho))
  
# show SSB rho as function of catch multiplier for the three change years
rhoplot <- ggplot(res, aes(x=Cmult, y=SSBrho, color=as.factor(ChangeYear))) +
  geom_point() +
  geom_line() +
  geom_point(data = bestres, shape = 1, size=5) +
  geom_hline(yintercept = 0, linetype="dashed") +
  labs(color="Change Year") +
  xlab("Catch Multiplier") +
  theme_bw()

print(rhoplot)
ggsave(".\\witch\\rhoplot.png", rhoplot)

# identify the four asap runs and get the rdat files
asapfname <- "y2010c10m10"
asapcmultfnames <- paste0("y", bestres$ChangeYear, "c", bestres$Cmult * 10, "m10")
asap <- dget(paste0(".\\rundir\\", asapfname, "_000.rdat"))
asap1 <- dget(paste0(".\\rundir\\", asapcmultfnames[1], "_000.rdat"))
asap2 <- dget(paste0(".\\rundir\\", asapcmultfnames[2], "_000.rdat"))
asap3 <- dget(paste0(".\\rundir\\", asapcmultfnames[3], "_000.rdat"))

years <- seq(asap$parms$styr, asap$parms$endyr)
nyears <- asap$parms$nyears
tsdf <- data.frame(Year = rep(years, 8),
                   Source = rep(c(rep("Base", nyears), 
                              paste("Change Year", rep(bestres$ChangeYear, each = nyears))), 2),
                   metric = rep(c("SSB", "F"), each = (nyears * 4)),
                   value = c(asap$SSB, asap1$SSB, asap2$SSB, asap3$SSB,
                             asap$F.report, asap1$F.report, asap2$F.report, asap3$F.report))

tsplot <- ggplot(tsdf, aes(x=Year, y=value, color=Source)) +
  geom_point() +
  geom_line() +
  expand_limits(y=0) +
  facet_wrap(~ metric, scales="free_y") +
  theme_bw() +
  theme(legend.position = "bottom")

print(tsplot)
ggsave(".\\witch\\tsplot.png", tsplot)
