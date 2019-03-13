source(".\\Rcode\\03_plot_witch_retros.R")

# 04_catch_advice_witch.R
# calculate catch advice under F40% for base, rho adjusted, and three catch multiplier scenarios

# compare fleet selectivity in final year
nages <- asap$parms$nages
ages <- seq(1, nages)
seldf <- data.frame(Age = rep(ages, 4),
                    Source = rep(c("Base", sourcenames), each=nages),
                    Selectivity = c(asap$fleet.sel.mats[[1]][nyears, ],
                                    asap1$fleet.sel.mats[[1]][nyears, ],
                                    asap2$fleet.sel.mats[[1]][nyears, ],
                                    asap3$fleet.sel.mats[[1]][nyears, ]) )

selplot <- ggplot(seldf, aes(x=Age, y=Selectivity, color=Source)) +
  geom_point() +
  geom_line() +
  expand_limits(y=0) +
  scale_color_manual(values = my.col[c(1, 2, 3, 6)]) +
  theme_bw()

print(selplot)
ggsave(".\\witch\\selplot.png", selplot)

total4 <- asap4$F.age[nyears, ] / max(asap4$F.age[nyears, ])
total5 <- asap5$F.age[nyears, ] / max(asap5$F.age[nyears, ])
my.lines <- c("solid", "dashed", "solid", "dashed", "solid")
selfleetdf <- data.frame(Age = rep(ages, 5),
                         Source = rep(c("Base", 
                                        paste(fleetnames, "Orig Fleet"), 
                                        paste(fleetnames, "Total")), each=nages),
                         Selectivity = c(asap$fleet.sel.mats[[1]][nyears, ],
                                         asap4$fleet.sel.mats[[1]][nyears, ],
                                         asap5$fleet.sel.mats[[1]][nyears, ],
                                         total4,
                                         total5))

selfleetplot <- ggplot(selfleetdf, aes(x=Age, y=Selectivity, group=Source)) +
  geom_point(aes(color=Source)) +
  geom_line(aes(linetype=Source, color=Source)) +
  expand_limits(y=0) +
  scale_color_manual(values = my.col[c(5, 5, 4, 4, 6)]) +
  scale_linetype_manual(values = my.lines) +
  theme_bw()

print(selfleetplot)
ggsave(".\\witch\\selfleetplot.png", selfleetplot)

selmdf <- data.frame(Age = rep(ages, 4),
                     Source = rep(c("Base", mnames), each=nages),
                     Selectivity = c(asap$fleet.sel.mats[[1]][nyears, ],
                                     asap6$fleet.sel.mats[[1]][nyears, ],
                                     asap7$fleet.sel.mats[[1]][nyears, ],
                                     asap8$fleet.sel.mats[[1]][nyears, ]) )

selmplot <- ggplot(selmdf, aes(x=Age, y=Selectivity, color=Source)) +
  geom_point() +
  geom_line() +
  expand_limits(y=0) +
  scale_color_manual(values = my.col[c(7, 8, 9, 6)]) +
  theme_bw()

print(selmplot)
ggsave(".\\witch\\selmplot.png", selmplot)

# calculate F40% from ASAPplot
# do it for each of the asap runs
a1 <- list(asap.name = asapfname)
PlotSPRtable(asap, a1, 5, FALSE, ".\\witch\\", "png")
sprtab <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapfname, ".csv"))
asapF40 <- sprtab$F..SPR.[sprtab$X.SPR == 0.40]

a11 <- list(asap.name = asapcmultfnames[1])
PlotSPRtable(asap1, a11, 5, FALSE, ".\\witch\\", "png")
sprtab1 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[1], ".csv"))
asap1F40 <- sprtab1$F..SPR.[sprtab1$X.SPR == 0.40]

a12 <- list(asap.name = asapcmultfnames[2])
PlotSPRtable(asap2, a12, 5, FALSE, ".\\witch\\", "png")
sprtab2 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[2], ".csv"))
asap2F40 <- sprtab2$F..SPR.[sprtab2$X.SPR == 0.40]

a13 <- list(asap.name = asapcmultfnames[3])
PlotSPRtable(asap3, a13, 5, FALSE, ".\\witch\\", "png")
sprtab3 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapcmultfnames[3], ".csv"))
asap3F40 <- sprtab3$F..SPR.[sprtab3$X.SPR == 0.40]

# can't calc the simple way for Young and Old cases cuz added catch has different selectivity pattern
# replace total F matrix with fleet 1 F matrix to compute F40
# note selectivity values saved in AgePro csv will then correspond to fleet 1 only as well
a14 <- list(asap.name = asapfleetfnames[1])
asap4mod <- asap4
asap4mod$F.age <- asap4$fleet.FAA[[1]]
PlotSPRtable(asap4mod, a14, 5, FALSE, ".\\witch\\", "png")
sprtab4 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapfleetfnames[1], ".csv"))
asap4F40 <- sprtab4$F..SPR.[sprtab4$X.SPR == 0.40]

a15 <- list(asap.name = asapfleetfnames[2])
asap5mod <- asap5
asap5mod$F.age <- asap5$fleet.FAA[[1]]
PlotSPRtable(asap5mod, a15, 5, FALSE, ".\\witch\\", "png")
sprtab5 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapfleetfnames[2], ".csv"))
asap5F40 <- sprtab5$F..SPR.[sprtab5$X.SPR == 0.40]

# replace mmult modified M with original M value for F40 calculations
# then run PlotSPRtable function with mmult values for use in short term projections
a16 <- list(asap.name = asapmmultfnames[1])
asap6mod <- asap6
asap6mod$M.age <- asap$M.age
PlotSPRtable(asap6mod, a16, 5, FALSE, ".\\witch\\", "png")
sprtab6 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapmmultfnames[1], ".csv"))
asap6F40 <- sprtab6$F..SPR.[sprtab6$X.SPR == 0.40]
PlotSPRtable(asap6, a16, 5, FALSE, ".\\witch\\", "png")

a17 <- list(asap.name = asapmmultfnames[2])
asap7mod <- asap7
asap7mod$M.age <- asap$M.age
PlotSPRtable(asap7mod, a17, 5, FALSE, ".\\witch\\", "png")
sprtab7 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapmmultfnames[2], ".csv"))
asap7F40 <- sprtab7$F..SPR.[sprtab7$X.SPR == 0.40]
PlotSPRtable(asap7, a17, 5, FALSE, ".\\witch\\", "png")

a18 <- list(asap.name = asapmmultfnames[3])
asap8mod <- asap8
asap8mod$M.age <- asap$M.age
PlotSPRtable(asap8mod, a18, 5, FALSE, ".\\witch\\", "png")
sprtab8 <- read.csv(paste0(".\\witch\\SPR.Target.Table_", asapmmultfnames[3], ".csv"))
asap8F40 <- sprtab8$F..SPR.[sprtab8$X.SPR == 0.40]
PlotSPRtable(asap8, a18, 5, FALSE, ".\\witch\\", "png")

# create F40 data frames and plot against each other
f40df <- data.frame(Source = c("Base", sourcenames),
                    F40 = c(asapF40, asap1F40, asap2F40, asap3F40))

f40plot <- ggplot(f40df, aes(x=Source, y=F40, fill=Source)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(F40, 4)), vjust=1.6, color="white", size=3.5) + 
  scale_fill_manual(values = my.col[c(1, 2, 3, 6)]) +
  theme_bw()

print(f40plot)
ggsave(".\\witch\\F40.png", f40plot)

f40fdf <- data.frame(Source = c("Base", sourcenames[2], fleetnames),
                     F40 = c(asapF40, asap2F40, asap4F40, asap5F40))

f40fplot <- ggplot(f40fdf, aes(x=Source, y=F40, fill=Source)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(F40, 4)), vjust=1.6, color="white", size=3.5) + 
  scale_fill_manual(values = my.col[c(2, 4, 5, 6)]) +
  theme_bw()

print(f40fplot)
ggsave(".\\witch\\F40fleet.png", f40fplot)

f40mdf <- data.frame(Source = c("Base", mnames),
                     F40 = c(asapF40, asap6F40, asap7F40, asap8F40))

f40mplot <- ggplot(f40mdf, aes(x=Source, y=F40, fill=Source)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(F40, 4)), vjust=1.6, color="white", size=3.5) + 
  scale_fill_manual(values = my.col[c(7, 8, 9, 6)]) +
  theme_bw()

print(f40mplot)
ggsave(".\\witch\\F40m.png", f40mplot)

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
# rem AgePro files for Young and Old based on fleet 1, so can use them here
stp4 <- calcShortTermProj(asapfleetfnames[1], asap4$N.age[nyears, ], mean(asap4$N.age[, 1]), asap4F40, nprojyears)
stp5 <- calcShortTermProj(asapfleetfnames[2], asap5$N.age[nyears, ], mean(asap5$N.age[, 1]), asap5F40, nprojyears)
stp6 <- calcShortTermProj(asapmmultfnames[1], asap6$N.age[nyears, ], mean(asap6$N.age[, 1]), asap6F40, nprojyears)
stp7 <- calcShortTermProj(asapmmultfnames[2], asap7$N.age[nyears, ], mean(asap7$N.age[, 1]), asap7F40, nprojyears)
stp8 <- calcShortTermProj(asapmmultfnames[3], asap8$N.age[nyears, ], mean(asap8$N.age[, 1]), asap8F40, nprojyears)

cmult <- as.numeric(substr(asapcmultfnames, 7, 8)) / 10
stpdf <- data.frame(Source = rep(c("Base",  sourcenames, 
                                   "Base rho adj", paste0(sourcenames, " C adj")), each=nprojyears),
                    Year = rep(asap$parms$endyr + 1:nprojyears, 8),
                    Catch = c(stp, stp1, stp2, stp3, 
                              stprhoadj, stp1/cmult[1], stp2/cmult[2], stp3/cmult[3]),
                    Adjusted = rep(c(FALSE, TRUE), each = (4 * nprojyears)))

stpplot <- ggplot(filter(stpdf, Adjusted == FALSE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle(paste(asap$parms$endyr, " Catch = ", round(asap$catch.obs[nyears], 0), " mt")) +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  scale_fill_manual(values = my.col[c(1, 2, 3, 6)]) +
  theme_bw()
print(stpplot)
ggsave(".\\witch\\short_term_projections.png", stpplot)

stpplotadj <- ggplot(filter(stpdf, Adjusted == TRUE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle("When catch adjustments are made to quota") +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  scale_fill_manual(values = my.col[c(1, 2, 3, 6)]) +
  theme_bw()
print(stpplotadj)
ggsave(".\\witch\\short_term_projections_adjusted.png", stpplotadj)

fcmult <- bestresfleet$cmult[2:3]
stpfdf <- data.frame(Source = rep(c("Base", sourcenames[2], fleetnames,
                                    "Base rho adj", paste0(c(sourcenames[2], fleetnames), " C adj")),
                                  each=nprojyears),
                     Year = rep(asap$parms$endyr + 1:nprojyears, 8),
                     Catch = c(stp, stp2, stp4, stp5, 
                               stprhoadj, stp2/cmult[2], stp4/fcmult[1], stp5/fcmult[2]),
                     Adjusted = rep(c(FALSE, TRUE), each = (4 * nprojyears)))

stpfplot <- ggplot(filter(stpfdf, Adjusted == FALSE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle(paste(asap$parms$endyr, " Catch = ", round(asap$catch.obs[nyears], 0), " mt")) +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  scale_fill_manual(values = my.col[c(2, 4, 5, 6)]) +
  theme_bw()
print(stpfplot)
ggsave(".\\witch\\short_term_projections_fleet.png", stpfplot)

stpfplotadj <- ggplot(filter(stpfdf, Adjusted == TRUE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle("When catch adjustments are made to quota") +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  scale_fill_manual(values = my.col[c(2, 4, 5, 6)]) +
  theme_bw()
print(stpfplotadj)
ggsave(".\\witch\\short_term_projections_fleet_adjusted.png", stpfplotadj)

# M short term projection plot
stpmdf <- data.frame(Source = rep(c("Base",  "Base rho adj", mnames), each=nprojyears),
                     Year = rep(asap$parms$endyr + 1:nprojyears, 5),
                     Catch = c(stp, stprhoadj, stp6, stp7, stp8))

stpmplot <- ggplot(stpmdf, aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle(paste(asap$parms$endyr, " Catch = ", round(asap$catch.obs[nyears], 0), " mt")) +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  scale_fill_manual(values = c(my.col[c(7, 8, 9, 6)], "pink")) +
  theme_bw()
print(stpmplot)
ggsave(".\\witch\\short_term_projections_m.png", stpmplot)

