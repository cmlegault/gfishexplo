# adjusts asap.dat object by multiplying catch and M by cmult and mmult for years >= year
adjust_asap <- function(asap.dat,year,cmult,mmult){
  catch.mat <- asap.dat$dat[names(asap.dat$dat) == "CAA_mats"]
  m.mat <- asap.dat$dat[names(asap.dat$dat) == "M"]
  years <- seq(as.numeric(asap.dat$dat[names(asap.dat$dat) == "year1"]),
               as.numeric(asap.dat$dat[names(asap.dat$dat) == "year1"]) + 
               as.numeric(asap.dat$dat[names(asap.dat$dat) == "n_years"]) - 1 , 1)
  catch.mat.adj <- catch.mat[[1]][[1]]
  nc <- length(catch.mat.adj[1,])
  year.count <- 1:length(years)
  catch.mat.adj[year.count[years >= year],nc] <- catch.mat.adj[year.count[years >= year],nc] * cmult
  m.mat.adj <- m.mat[[1]]
  m.mat.adj[year.count[years >= year],] <- m.mat.adj[year.count[years >= year],] * mmult
  asap.dat.adj <- asap.dat
  asap.dat.adj$dat[names(asap.dat$dat) == "CAA_mats"][[1]] <- catch.mat.adj
  asap.dat.adj$dat[names(asap.dat$dat) == "M"][[1]] <- m.mat.adj
  return(asap.dat.adj)
}
