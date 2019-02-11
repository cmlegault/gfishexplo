# calculated SSB Mohn's rho from retrospective analysis with n.peels peels
# assumes rdat files created for each peel of fname
calc_SSBrho <- function(fname,n.peels){
  n.char <- nchar(fname)
  fname.base <- substr(fname,1,n.char-4)
  ssb <- list()
  for (i in 0:n.peels){
    asap.name <- paste0(fname.base,"_00",i,".rdat")
    asap <- dget(asap.name)
    ssb[[i+1]] <- asap$SSB
  }
  
  ssb.base <- ssb[[1]]
  rho <- rep(NA, n.peels)
  for (i in 1:n.peels){
     ssb.use <- ssb[[i+1]]
     n.y <- length(ssb.use)
     rho[i] <- (ssb.use[n.y] - ssb.base[n.y]) / ssb.base[n.y]
  }
  ssb.rho <- mean(rho, na.rm=T)
  return(ssb.rho) 
}
