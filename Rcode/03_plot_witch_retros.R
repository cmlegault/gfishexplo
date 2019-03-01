# 03_plot_witch_retros.R
# make some summary and comparison plots for the base run and 3 catch multiplier runs with no retro

# uncomment following line if need to install latest version of ASAPplots
# devtools::install_github("cmlegault/ASAPplots", build_vignettes = TRUE)
library("scales")
library("ASAPplots")
library("ggplot2")
library("dplyr")

# to use consistent colors throughout
my.col <- hue_pal()(6)

res <- read.csv(".\\witch\\witch_retro_res.csv")
resfleet <- read.csv(".\\witch\\witch_retro_res_fleet.csv")

bestres <- res %>%
  mutate(absrho = abs(SSBrho)) %>%
  group_by(ChangeYear) %>%
  filter(absrho == min(absrho))
  
bestresfleet <- resfleet %>%
  mutate(absrho = abs(SSBrho)) %>%
  group_by(Source) %>%
  filter(absrho == min(absrho))

# show SSB rho as function of catch multiplier for the three change years
rhoplot <- ggplot(res, aes(x=Cmult, y=SSBrho, color=as.factor(ChangeYear))) +
  geom_point() +
  geom_line() +
  geom_point(data = bestres, shape = 1, size=5) +
  geom_hline(yintercept = 0, linetype="dashed") +
  labs(color="Change Year") +
  scale_color_manual(values = my.col[c(1, 2, 3)]) +
  xlab("Catch Multiplier") +
  theme_bw()

print(rhoplot)
ggsave(".\\witch\\rhoplot.png", rhoplot)

rhoplotfleet <- ggplot(filter(resfleet, Source != "2005 Cx3"), aes(x=cmult, y=SSBrho, color=Source)) +
  geom_point() +
  geom_line() +
  geom_point(data = filter(bestresfleet, Source != "2005 Cx3"), shape = 1, size=5) +
  scale_color_manual(values = my.col[c(4, 5)]) +
  geom_hline(yintercept = 0, linetype="dashed") +
  xlab("Catch Multiplier") +
  theme_bw()

print(rhoplotfleet)
ggsave(".\\witch\\rhoplotfleet.png", rhoplotfleet)

# identify the asap runs
asapfname <- "y2010c10m10"
asapcmultfnames <- paste0("y", bestres$ChangeYear, "c", bestres$Cmult * 10, "m10")
sourcenames <- paste0(bestres$ChangeYear, " Cx", bestres$Cmult)
asapfleetfnames <- c(paste0("Young_y", bestresfleet$Year[bestresfleet$Source == "2005 Young"],
                            "c", bestresfleet$cmult[bestresfleet$Source == "2005 Young"] * 10),
                     paste0("Old_y", bestresfleet$Year[bestresfleet$Source == "2005 Old"],
                            "c", bestresfleet$cmult[bestresfleet$Source == "2005 Old"] * 10))
fleetnames <- paste0(bestresfleet$Source[2:3], "x", bestresfleet$cmult[2:3])

# copy the rdat files to witch directory
shell(paste0("copy .\\rundir\\", asapfname, "_000.rdat .\\witch\\"))
shell(paste0("copy .\\rundir\\", asapcmultfnames[1], "_000.rdat .\\witch\\"))
shell(paste0("copy .\\rundir\\", asapcmultfnames[2], "_000.rdat .\\witch\\"))
shell(paste0("copy .\\rundir\\", asapcmultfnames[3], "_000.rdat .\\witch\\"))
shell(paste0("copy .\\rundir\\", asapfleetfnames[1], "_000.rdat .\\witch\\"))
shell(paste0("copy .\\rundir\\", asapfleetfnames[2], "_000.rdat .\\witch\\"))

# read the rdat files
asap <- dget(paste0(".\\witch\\", asapfname, "_000.rdat"))
asap1 <- dget(paste0(".\\witch\\", asapcmultfnames[1], "_000.rdat"))
asap2 <- dget(paste0(".\\witch\\", asapcmultfnames[2], "_000.rdat"))
asap3 <- dget(paste0(".\\witch\\", asapcmultfnames[3], "_000.rdat"))
asap4 <- dget(paste0(".\\witch\\", asapfleetfnames[1], "_000.rdat"))
asap5 <- dget(paste0(".\\witch\\", asapfleetfnames[2], "_000.rdat"))

# plot time series of catch, F, recruits, and SSB
years <- seq(asap$parms$styr, asap$parms$endyr)
nyears <- asap$parms$nyears
tsdf <- data.frame(Year = rep(years, 16),
                   Source = rep(rep(c("Base", sourcenames), each=nyears), 4), 
                   metric = rep(c("SSB", "F", "Recruits", "Catch"), each = (nyears * 4)),
                   value = c(asap$SSB, asap1$SSB, asap2$SSB, asap3$SSB,
                             asap$F.report, asap1$F.report, asap2$F.report, asap3$F.report,
                             asap$N.age[,1], asap1$N.age[,1], asap2$N.age[,1], asap3$N.age[,1],
                             asap$catch.obs, asap1$catch.obs, asap2$catch.obs, asap3$catch.obs))

tsplot <- ggplot(tsdf, aes(x=Year, y=value, color=Source)) +
  geom_point() +
  geom_line() +
  expand_limits(y=0) +
  facet_wrap(~ metric, scales="free_y") +
  scale_color_manual(values = my.col[c(1, 2, 3, 6)]) +
  theme_bw() +
  theme(legend.position = "bottom")

print(tsplot)
ggsave(".\\witch\\tsplot.png", tsplot)

fdf <- data.frame(Year = rep(years, 16),
                  Source = rep(rep(c("Base", sourcenames[2], fleetnames), each=nyears), 4), 
                  metric = rep(c("SSB", "F", "Recruits", "Catch"), each = (nyears * 4)),
                  value = c(asap$SSB, asap2$SSB, asap4$SSB, asap5$SSB,
                            asap$F.report, asap2$F.report, asap4$F.report, asap5$F.report,
                            asap$N.age[,1], asap2$N.age[,1], asap4$N.age[,1], asap5$N.age[,1],
                            asap$catch.obs, asap2$catch.obs, apply(asap4$catch.obs, 2, sum), 
                            apply(asap5$catch.obs, 2, sum)))

ftsplot <- ggplot(fdf, aes(x=Year, y=value, color=Source)) +
  geom_point() +
  geom_line() +
  scale_color_manual(values = my.col[c(2, 4, 5, 6)]) +
  expand_limits(y=0) +
  facet_wrap(~ metric, scales="free_y") +
  theme_bw() +
  theme(legend.position = "bottom")

print(ftsplot)
ggsave(".\\witch\\ftsplot.png", ftsplot)

# get retro plots from ASAPplot 
windows(record = TRUE)
PlotRetroWrapper(".\\rundir", paste0(asapfname, "_000"), asap, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapfname,".png"))
PlotRetroWrapper(".\\rundir", paste0(asapcmultfnames[1], "_000"), asap1, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapcmultfnames[1],".png"))
PlotRetroWrapper(".\\rundir", paste0(asapcmultfnames[2], "_000"), asap2, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapcmultfnames[2],".png"))
PlotRetroWrapper(".\\rundir", paste0(asapcmultfnames[3], "_000"), asap3, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapcmultfnames[3],".png"))
PlotRetroWrapper(".\\rundir", paste0(asapfleetfnames[1], "_000"), asap4, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapfleetfnames[1],".png"))
PlotRetroWrapper(".\\rundir", paste0(asapfleetfnames[2], "_000"), asap5, TRUE, ".\\rundir\\", "png")
shell(paste0("copy .\\rundir\\retro_F_SSB_R.png .\\witch\\retro_F_SSB_R_", asapfleetfnames[2],".png"))
dev.off()


#### just a check to make sure everything worked correctly (yep, it did)
# make sure the catch in fleet 2 is being done correctly for young and old cases
mydf <- data.frame(source = character(),
                   year = integer(),
                   cmult = double(),
                   catchobs1 = double(),
                   catchobs2 = double())

nyears <- 34

for (i in 1:8){
  cmult <- my.fleet.mults[i]
  fnamey <- paste0("Young_y2005c", cmult*10, "_000.rdat")
  fnameo <- paste0("Old_y2005c", cmult*10, "_000.rdat")
  asapy <- dget(paste0(".\\rundir\\", fnamey))
  asapo <- dget(paste0(".\\rundir\\", fnameo))
  thisdf <- data.frame(source = c(rep("Young", nyears), rep("Old", nyears)),
                       year = rep(1982:2015, 2),
                       cmult = cmult,
                       catchobs1 = c(asapy$catch.obs[1,], asapo$catch.obs[1,]),
                       catchobs2 = c(asapy$catch.obs[2,], asapo$catch.obs[2,]))
  mydf <- rbind(mydf, thisdf)
}
mydf

mydfplot1 <- ggplot(mydf, aes(x=year, y=catchobs1, color=as.factor(cmult))) +
  geom_point() +
  geom_line() +
  facet_wrap(~source) +
  theme_bw()
print(mydfplot1)

mydfplot2 <- ggplot(mydf, aes(x=year, y=catchobs2, color=as.factor(cmult))) +
  geom_point() +
  geom_line() +
  facet_wrap(~source) +
  theme_bw()
print(mydfplot2)

