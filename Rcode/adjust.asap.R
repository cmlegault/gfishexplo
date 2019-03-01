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

# adjusts asap.dat object by setting catch in fleet 2 to cmult time catch in fleet 1 for years >= year
# assumes starting file already set up with fleet 2 present and selectivity for fleet defined correctly
adjust_asap2 <- function(asap.dat,year,cmult){
  catch.mat <- asap.dat$dat[names(asap.dat$dat) == "CAA_mats"]
  years <- seq(as.numeric(asap.dat$dat[names(asap.dat$dat) == "year1"]),
               as.numeric(asap.dat$dat[names(asap.dat$dat) == "year1"]) + 
                 as.numeric(asap.dat$dat[names(asap.dat$dat) == "n_years"]) - 1 , 1)
  base.catch.mat <- catch.mat[[1]][[1]]
  catch.mat.adj <- catch.mat[[1]][[2]] * 0 # start with all zeros for proportions at age
  nc <- length(catch.mat.adj[1,])
  catch.mat.adj[, nc] <- 0.1 # set catch in all years to 0.1
  year.count <- 1:length(years)
  catch.mat.adj[year.count[years >= year],nc] <- base.catch.mat[year.count[years >= year],nc] * (cmult - 1) # note that one subtracted from cmult so has same meaning as adjust_asap (e.g., cmult=2 means total catch has doubled by including it once in real fleet and once in added fleet) - do not use cmult=1 here!
  asap.dat.adj <- asap.dat
  asap.dat.adj$dat[names(asap.dat$dat) == "CAA_mats"][[1]][[2]] <- catch.mat.adj
  return(asap.dat.adj)
}
