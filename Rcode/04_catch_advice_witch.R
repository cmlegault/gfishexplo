source(".\\Rcode\\03_plot_witch_retros.R")

# 04_catch_advice_witch.R
# calculate catch advice under F40% for base, rho adjusted, and three catch multiplier scenarios

# compare fleet selectivity in final year
nages <- asap$parms$nages
ages <- seq(1, nages)
seldf <- data.frame(Age = rep(ages, 4),
                    Source = rep(rep(c("Base", sourcenames), each=nages), 4),
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

# calculate F40% from ASAPplot
# do it for each of the four asap runs
windows(record=TRUE)
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

dev.off()

f40df <- data.frame(Source = c("Base", sourcenames),
                    F40 = c(asapF40, asap1F40, asap2F40, asap3F40))

f40plot <- ggplot(f40df, aes(x=Source, y=F40, fill=Source)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(F40, 4)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  theme_bw()

print(f40plot)
ggsave(".\\witch\\F40.png", f40plot)

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

cmult <- as.numeric(substr(asapcmultfnames, 7, 8)) / 10
#labnames <- paste0(substr(asapcmultfnames, 2, 5), " Cx",cmult) 
stpdf <- data.frame(Source = rep(c("Base",  sourcenames, 
                                   "Base rho adj", paste(sourcenames, " C adj")), each=nprojyears),
                    Year = rep(asap$parms$endyr + 1:nprojyears, 8),
                    Catch = c(stp, stp1, stp2, stp3, 
                              stprhoadj, stp1/cmult[1], stp2/cmult[2], stp3/cmult[3]),
                    Adjusted = rep(c(FALSE, TRUE), each = (4 * nprojyears)))

stpplot <- ggplot(filter(stpdf, Adjusted == FALSE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle(paste(asap$parms$endyr, " Catch = ", round(asap$catch.obs[nyears], 0), " mt")) +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  theme_bw()
print(stpplot)
ggsave(".\\witch\\short_term_projections.png", stpplot)

stpplotadj <- ggplot(filter(stpdf, Adjusted == TRUE), aes(x=Year, y=Catch, fill=Source)) +
  geom_bar(stat="identity", position=position_dodge()) +
  ggtitle("When catch adjustments are made to quota") +
  geom_text(aes(label=round(Catch, 0)), vjust=1.6, color="white", size=3.5, 
            position=position_dodge(0.9)) +
  theme_bw()
print(stpplotadj)
ggsave(".\\witch\\short_term_projections_adjusted.png", stpplotadj)


