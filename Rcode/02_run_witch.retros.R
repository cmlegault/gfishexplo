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
                        n.peels=7,
                        year.range=my.year.range,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)

# check to see if close enough with current cmults, if not need to do some more runs
ifelse(min(abs(res1[,4])) < 0.05, "OK", "Need more runs")

# set another break point annd search over same multipliers
my.year.range2 <- c(2005, 2005)
res2 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=7,
                        year.range=my.year.range2,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res2[,4])) < 0.05, "OK", "Need more runs")

# final break point for catch multipliers
my.year.range3 <- c(2000, 2000)
res3 <- run_retro_mults(asap.fname=my.asap.fname,
                        n.peels=7,
                        year.range=my.year.range3,
                        cmult.vals=my.mults,
                        mmult.vals=1,
                        save.files=TRUE)
ifelse(min(abs(res3[,4])) < 0.05, "OK", "Need more runs")


# combine results into one csv file
res <- rbind(res1, res2, res3)
write.csv(res, file="witch_retro_res.csv", row.names=F)

# return working directory to starting directory
setwd(base.dir)






# # make catch and M multiplier plots
# my.years <- my.year.range[1]:my.year.range[2]
# n.years <- length(my.years)
# b.res <- cbind(my.years,rep(1,n.years),rep(res1[1,4],n.years))
# c.res <- res2[,c(1,2,4)]
# catch.res <- rbind(b.res,c.res)
# m.res <- res3[,c(1,3,4)]
# M.res <- rbind(b.res,m.res)
# 
# create.res.mat <- function(a.res,yrbreak,a.mult){
#   resmat <- matrix(NA, nrow=length(yrbreak), ncol=length(a.mult))
#   rownames(resmat) <- yrbreak
#   colnames(resmat) <- a.mult
#   row.val <- 1:length(yrbreak)
#   col.val <- 1:length(a.mult)
#   for (k in 1:length(a.res[,1])){
#     ii <- row.val[rownames(resmat) == a.res[k,1]]
#     jj <- col.val[colnames(resmat) == a.res[k,2]]
#     resmat[ii,jj] <- a.res[k,3]
#   }
#   return(resmat)
# }
# 
# rho.cutoff <- 0.05
# catch.res.mat <- create.res.mat(catch.res,my.years,c(1,my.mults))
# M.res.mat <- create.res.mat(M.res,my.years,c(1,my.mults))
# c.points <- catch.res[abs(catch.res[,3]) < rho.cutoff, c(2,1,3)]
# m.points <- M.res[abs(M.res[,3]) < rho.cutoff, c(2,1,3)]
# 
# windows(record=T)
# filled.contour(x=c(1,my.mults), y=my.years, z=t(catch.res.mat), zlim=c(-0.7,0.7),nlevels=15,col=rainbow(20), plot.title=title(main="SSBrho",xlab="Catch multiplier",ylab="Year Break"), plot.axes ={axis(1);axis(2);points(c.points[,1],c.points[,2],pch=16,cex=1.5)})
# savePlot("SSBrho_contour_catch_multipliers.png", type='png')
# 
# filled.contour(x=c(1,my.mults), y=my.years, z=t(M.res.mat), zlim=c(-0.7,0.7),nlevels=15,col=rainbow(20), plot.title=title(main="SSBrho",xlab="M multiplier",ylab="Year Break"), plot.axes ={axis(1);axis(2);points(m.points[,1],m.points[,2],pch=16,cex=1.5)})
# savePlot("SSBrho_contour_M_multipliers.png", type='png')
