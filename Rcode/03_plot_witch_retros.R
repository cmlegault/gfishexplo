# plot_witch_retros.R
# make some summary and comparison plots for the base run and 3 catch multiplier runs with no retro

# uncomment following line if need to install latest version of ASAPplots
# devtools::install_github("cmlegault/ASAPplots", build_vignettes = TRUE)
library("ASAPplots")
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

# plot time series of catch, F, recruits, and SSB
years <- seq(asap$parms$styr, asap$parms$endyr)
nyears <- asap$parms$nyears
tsdf <- data.frame(Year = rep(years, 16),
                   Source = rep(c(rep("Base", nyears), 
                              paste("Change Year", rep(bestres$ChangeYear, each = nyears))), 4),
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
  theme_bw() +
  theme(legend.position = "bottom")

print(tsplot)
ggsave(".\\witch\\tsplot.png", tsplot)

# compare fleet selectivity in final year
nages <- asap$parms$nages
ages <- seq(1, nages)
seldf <- data.frame(Age = rep(ages, 4),
                    Source = c(rep("Base", nages), 
                               paste("Change Year", rep(bestres$ChangeYear, each = nages))),
                    Selectivity = c(asap$fleet.sel.mats[[1]][nyears, ],
                                    asap1$fleet.sel.mats[[1]][nyears, ],
                                    asap2$fleet.sel.mats[[1]][nyears, ],
                                    asap3$fleet.sel.mats[[1]][nyears, ]) )

selplot <- ggplot(seldf, aes(x=Age, y=Selectivity, color=Source)) +
  geom_point() +
  geom_line() +
  expand_limits(y=0) +
  theme_bw()

print(selplot)
ggsave(".\\witch\\selplot.png", selplot)

# get retro plots from ASAPplot (don't know why rho values don't print correctly)
windows(record = TRUE)
PlotRetroWrapper(".\\rundir", paste0(asapfname, "_000"), asap, TRUE, ".\\witch\\", "png")

# calculate F40% from ASAPplot
# do it for each of the four asap runs
a1 <- list(asap.name = asapfname)
PlotSPRtable(asap, a1, 5, TRUE, ".\\witch\\", "png")
sprtab <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapfname, ".csv"))
asapF40 <- sprtab$F..SPR.[sprtab$X.SPR == 0.40]

a11 <- list(asap.name = asapcmultfnames[1])
PlotSPRtable(asap1, a11, 5, TRUE, ".\\witch\\", "png")
sprtab1 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[1], ".csv"))
asap1F40 <- sprtab1$F..SPR.[sprtab1$X.SPR == 0.40]

a12 <- list(asap.name = asapcmultfnames[2])
PlotSPRtable(asap2, a12, 5, TRUE, ".\\witch\\", "png")
sprtab2 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[2], ".csv"))
asap2F40 <- sprtab2$F..SPR.[sprtab2$X.SPR == 0.40]

a13 <- list(asap.name = asapcmultfnames[3])
PlotSPRtable(asap3, a13, 5, TRUE, ".\\witch\\", "png")
sprtab3 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[3], ".csv"))
asap3F40 <- sprtab3$F..SPR.[sprtab3$X.SPR == 0.40]

cbind(asapF40, asap1F40, asap2F40, asap3F40)

dev.off()

# do short term projections under F40%
calcShortTermProj <- function(asap.name, startNAA, recruits, Fmult, nyears){
  nages <- length(startNAA)
  vals <- read.csv(paste0(".\\witch\\AGEPRO_ave_params_", asap.name, ".csv"))
  MAA <- as.numeric(vals[vals$X == "M.age", 2:(nages+1)])
  matAA <- as.numeric(vals[vals$X == "mat.age", 2:(nages+1)])
  WAA <- as.numeric(vals[vals$X == "catch.waa", 2:(nages+1)])
  selx <- as.numeric(vals[vals$X == "sel.age", 2:(nages+1)])
  FAA <- Fmult * selx
  ZAA <- MAA + FAA
  ctot <- rep(NA, nyears)
  NAA <- matrix(NA, nrow=(nyears+1), ncol=nages)
  NAA[1, ] <- startNAA
  NAA[2:(nyears+1), 1] <- recruits
  for (iyear in 1:nyears){
    for (iage in 1:(nages-1)){
      NAA[iyear+1, iage+1] <- NAA[iyear, iage] * exp(-ZAA[iage])
    }
    NAA[iyear+1, nages] <- NAA[iyear+1, nages] * exp(-ZAA[nages])
    ctot[iyear] <- sum(NAA[iyear, ] * WAA* FAA * (1 - exp(-ZAA)) / ZAA)
  }
  return(ctot)
}

nprojyears <- 3
stp <- calcShortTermProj(asapfname, asap$N.age[nyears, ], mean(asap$N.age[, 1]), asapF40, nprojyears)
ssbrho <- res$SSBrho[1]
Nrhoadj <- asap$N.age[nyears, ] / (1 + ssbrho)
stprhoadj <- calcShortTermProj(asapfname, Nrhoadj, mean(asap$N.age[, 1]), asapF40, nprojyears)
stp1 <- calcShortTermProj(asapcmultfnames[1], asap1$N.age[nyears, ], mean(asap1$N.age[, 1]), asap1F40, nprojyears)
stp2 <- calcShortTermProj(asapcmultfnames[2], asap2$N.age[nyears, ], mean(asap2$N.age[, 1]), asap2F40, nprojyears)
stp3 <- calcShortTermProj(asapcmultfnames[3], asap3$N.age[nyears, ], mean(asap3$N.age[, 1]), asap3F40, nprojyears)

stpdf <- data.frame(Source = rep(c("Base", "Base rho adj", asapcmultfnames), each=nprojyears),
                    Year = rep(1:nprojyears, 5),
                    Catch = c(stp, stprhoadj, stp1, stp2, stp3))

stpplot <- ggplot(stpdf, aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  theme_bw()
print(stpplot)
ggsave(".\\witch\\short_term_projections.png", stpplot)

# make another plot for adjusting catch according to catch multiplier
# make another plot showing catch ratio relative to base or catch in terminal year (better)
# improve the names shown in the legend