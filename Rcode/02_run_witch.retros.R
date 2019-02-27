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

# set break point(s) and multipliers
my.year.range <- c(2010, 2010)
my.mults <- c(1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)

# catch multipliers (takes a little over 10 minutes to run)
res1 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=my.year.range,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)

# check to see if close enough with current cmults, if not need to do some more runs
ifelse(min(abs(res1[,4])) < 0.05, "OK", "Need more runs")

# set another break point annd search over same multipliers
my.year.range2 <- c(2005, 2005)
res2 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=my.year.range2,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res2[,4])) < 0.05, "OK", "Need more runs")

# final break point for catch multipliers
my.year.range3 <- c(2000, 2000)
res3 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=n.peels,
                        year.range=my.year.range3,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res3[,4])) < 0.05, "OK", "Need more runs")


# combine results into one csv file
res <- rbind(res1, res2, res3)
write.csv(res, file="witch_retro_res.csv", row.names=FALSE)
write.csv(res, file="..\\witch\\witch_retro_res.csv", row.names=FALSE)

################################################
# now handle the two fleet approach for change year = 2010

my.year.range <- c(2010, 2010)
my.fleet.mults <- c(1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)
base.rho <- res[1, 4]

# Young added catch (ages 2-5 all fully selected, other ages 0.1 selectivity)
my.fleet.name1 <- "YOUNG_FLEET.DAT"
shell(paste0("copy ..\\", my.dir, my.fleet.name1, " ."))
resfleet1 <- run_retro_mults2(asap.fname=my.fleet.name1,
                        n.peels=n.peels,
                        year.range=my.year.range,
                        cmult.vals=my.fleet.mults,
                        case.name="Young",
                        save.files=TRUE)

# Old added catch (ages 9-11+ fully selected, other ages zero selectivity)
my.fleet.name2 <- "OLD_FLEET.DAT"
shell(paste0("copy ..\\", my.dir, my.fleet.name2, " ."))
resfleet2 <- run_retro_mults2(asap.fname=my.fleet.name2,
                              n.peels=n.peels,
                              year.range=my.year.range,
                              cmult.vals=my.fleet.mults,
                              case.name="Old",
                              save.files=TRUE)

# make data frame of results
resfleet <- data.frame(Source = c(rep("2010 Cx2.5", 9), rep("2010 Young", 9), rep("2010 Old", 9)),
                       Year = rep(2010, 27),
                       cmult = rep(c(1, my.fleet.mults), 3),
                       SSBrho = c(res1$SSBrho, base.rho, resfleet1[,3], base.rho, resfleet2[,3]))
resfleet
write.csv(resfleet, file="witch_retro_res_fleet.csv", row.names=FALSE)
write.csv(resfleet, file="..\\witch\\witch_retro_res_fleet.csv", row.names=FALSE)

# return working directory to starting directory
setwd(base.dir)

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
  fnamey <- paste0("Young_y2010c", cmult*10, "_000.rdat")
  fnameo <- paste0("Old_y2010c", cmult*10, "_000.rdat")
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
