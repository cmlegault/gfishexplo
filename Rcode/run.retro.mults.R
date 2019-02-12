# function to run ASAP retros for range of change years, catch multipliers, and M multipliers
# change year is first year in second period
# catch and M multipliers applied to second period
# returns SSB rho from retrospective analysis for all combinations of change year, C and M mults
run_retro_mults <- function(asap.fname,n.peels,year.range,cmult.vals,mmult.vals,save.files=F){
  res <- matrix(NA, nrow=0, ncol=4)
  year.vals <- year.range[1]:year.range[2]
  n.years <- length(year.vals)
  n.cmults <- length(cmult.vals)
  n.mmults <- length(mmult.vals)
  
  asap.dat <- read.asap3.dat.file(asap.fname)
  terminal.year <- as.numeric(asap.dat$dat[1]) + as.numeric(asap.dat$dat[2]) - 1
  retro.first.year <- terminal.year - n.peels
  
  # loop through change years, cmults, mmults
  for (iy in 1:n.years){
    change.year <- year.vals[iy]
    for (ic in 1:n.cmults){
      cmult <- cmult.vals[ic]
      for (im in 1:n.mmults){
        mmult <- mmult.vals[im]
        
        asap.dat.adj <- adjust_asap(asap.dat,change.year,cmult,mmult)
        fname <- paste0("y", change.year, "c", cmult * 10, "m", mmult * 10, ".dat")
        header.text <- paste0("year=", change.year, ", catch mult=", cmult, ", m mult=", mmult)
        print(header.text)
        write.asap3.dat.file(fname,asap.dat.adj,header.text)
        
        shell(paste("ASAPRETRO.exe", fname, retro.first.year), intern=TRUE)
        ssbrho <- calc_SSBrho(fname, n.peels)
        res.vec <- c(change.year,cmult,mmult,ssbrho)
        res <- rbind(res,res.vec)
        if (save.files == FALSE) clean_up_files(fname)
      }
    }
  }
  colnames(res) <- c("ChangeYear", "Cmult", "Mmult", "SSBrho")
  rownames(res) <- NULL
  return(res)
} 
