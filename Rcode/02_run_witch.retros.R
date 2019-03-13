source(".\\Rcode\\01_source_functions.R")
base.dir <- getwd()

# Witch flounder example from SARC 62

# name and directory of original ASAP data file
my.asap.fname <- "Run_9Mc_FLAT_q056_5.DAT"
my.dir <- ".\\witch\\"

# move original file and exes to rundir (first make sure rundir exists and is empty)
# be very careful with this, could wipe out work, uncomment only if sure this is what you want to do
# if (dir.exists(".\\rundir")) shell("rm -rf .\\rundir")
dir.create(".\\rundir")
  
shell("copy .\\ASAPexecutables\\*.exe .\\rundir") 
shell(paste0("copy ", my.dir, my.asap.fname, " .\\rundir"))

# change working directory to rundir (make sure change back when done)
setwd(paste0(base.dir, "\\rundir"))

# use 7 year peel
n.peels <- 7

# set multipliers
my.mults <- c(1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)
nmults <- length(my.mults)

# catch multipliers (takes a little over 10 minutes to run)
res1 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=c(2010, 2010),
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)

# check to see if close enough with current cmults, if not need to do some more runs
ifelse(min(abs(res1[,4])) < 0.05, "OK", "Need more runs")

# set another break point annd search over same multipliers
res2 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=c(2005, 2005),
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res2[,4])) < 0.05, "OK", "Need more runs")

# final break point for catch multipliers
res3 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=c(2000, 2000),
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res3[,4])) < 0.05, "OK", "Need more runs")

res <- rbind(res1, res2, res3)
write.csv(res, file="..\\witch\\witch_retro_res.csv", row.names=FALSE)

################################################
# now handle the two fleet approach for change year = 2005
# note: encountered problems with convergence with change year was 2010 due to fleet disappearing in retros

# Young added catch (ages 2-5 all fully selected, other ages 0.1 selectivity)
my.fleet.name1 <- "YOUNG_FLEET.DAT"
shell(paste0("copy ..\\", my.dir, my.fleet.name1, " ."))
resfleet1 <- run_retro_mults2(asap.fname=my.fleet.name1,
                        n.peels=n.peels,
                        year.range=c(2005, 2005),
                        cmult.vals=my.mults,
                        case.name="Young",
                        save.files=TRUE)

# Old added catch (ages 9-11+ fully selected, other ages zero selectivity)
my.fleet.name2 <- "OLD_FLEET.DAT"
shell(paste0("copy ..\\", my.dir, my.fleet.name2, " ."))
resfleet2 <- run_retro_mults2(asap.fname=my.fleet.name2,
                              n.peels=n.peels,
                              year.range=c(2005, 2005),
                              cmult.vals=my.mults,
                              case.name="Old",
                              save.files=TRUE)

# make data frame of results
resfleet <- data.frame(Source = rep(c("2005 Cmult", "2005 Young", "2005 Old"), each=nmults),
                       Year = rep(2005, 3 * nmults),
                       cmult = rep(my.mults, 3),
                       SSBrho = c(res2$SSBrho, resfleet1[,3], resfleet2[,3]))
resfleet
write.csv(resfleet, file="..\\witch\\witch_retro_res_fleet.csv", row.names=FALSE)

################################################
# run increase M cases for comparison
resm1 <- run_retro_mults(asap.fname=my.asap.fname,
                         n.peels=n.peels,
                         year.range=c(2010, 2010),
                         cmult.vals=1,
                         mmult.vals=my.mults,
                         save.files=TRUE)
ifelse(min(abs(resm1[,4])) < 0.05, "OK", "Need more runs")

resm2 <- run_retro_mults(asap.fname=my.asap.fname,
                         n.peels=n.peels,
                         year.range=c(2005, 2005),
                         cmult.vals=1,
                         mmult.vals=my.mults,
                         save.files=TRUE)
ifelse(min(abs(resm2[,4])) < 0.05, "OK", "Need more runs")

resm3 <- run_retro_mults(asap.fname=my.asap.fname,
                         n.peels=n.peels,
                         year.range=c(2000, 2000),
                         cmult.vals=1,
                         mmult.vals=my.mults,
                         save.files=TRUE)
ifelse(min(abs(resm3[,4])) < 0.05, "OK", "Need more runs")

resm <- rbind(resm1, resm2, resm3)
write.csv(resm, file="..\\witch\\witch_retro_res_m.csv", row.names=FALSE)

################################################

# return working directory to starting directory
setwd(base.dir)

