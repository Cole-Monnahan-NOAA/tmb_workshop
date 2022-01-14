#Poisson GLMM

## Poisson modeling with mixed effects

## Generation and analysis of simulated data, e.g. Loco

set.seed(1234)

data.fn <- function(nsite = 8, nyear = 20, alpha = 0.5, beta1 = 0.5, beta2 = - 0.3, sd.site = 0.5, sd.year = 0.2){
   # nsite: Number of populations
   # nyear: Number of years
   # alpha, beta1, beta2, fixed coefficients
   # sd.site: standard deviation of the site level random effects
   # sd.year: standard deviation of the year effects

   # Generate data structures
   log.expected.count <- array(NA, dim = c(nyear, nsite))
   expected.count <- array(NA, dim = c(nyear, nsite))
   C <-  array(NA, dim = c(nyear, nsite))

   # Generate covariate values
   cov1 <- array(rnorm(nyear*nsite, mean = 0, sd = 1), dim = c(nyear, nsite))
   cov2 <- array(rnorm(nyear*nsite, mean = 0, sd = 1), dim = c(nyear, nsite))
   effort <- array( rgamma(nyear*nsite, shape = 4, rate = 2),dim = c(nyear, nsite) ) 

   # Draw two sets of random effects from their respective distributions
   re.site <- rnorm(n = nsite, mean = 0, sd = sd.site)
   re.year <- rnorm(n = nyear, mean = 0, sd = sd.year)

   # Loop over years and sites
   for(i in 1:nyear){
    for (j in 1:nsite){
      # random site and year effects on the intercept 
      log.expected.count[i,j] <- (alpha + re.site[j] + re.year[i]) + beta1*cov1[i,j] + beta2*cov2[i,j] + log(effort[i,j])
      expected.count[i,j] <- exp(log.expected.count[i,j])

      # Poisson observations of expected values 
      C[i,j] <- rpois(1, lambda = expected.count[i,j])
      }
   }
   
   

   return(list(nsite = nsite, nyear = nyear, sd.site = sd.site, alpha = alpha, beta1 = beta1, beta2 = beta2, effort = effort, cov1 = cov1, cov2 = cov2, sd.site = sd.site, sd.year = sd.year, expected.count = expected.count, C = C))
   }

loco <- data.fn(nsite = 8, nyear = 20, sd.site = 0.2, sd.year = 0.4)

#Plot catch
matplot(1:loco$nyear, loco$C, type = "l", lty = 1, lwd = 2, main = "", las = 1, ylab = "Catch", xlab = "Year")

#Plot Catch per unit effort
matplot(1:loco$nyear, loco$C/loco$effort, type = "l", lty = 1, lwd = 2, main = "", las = 1, ylab = "CPUE", xlab = "Year")

### Fit a GLM in TMB to Catch data
library(TMB)

#model for random effects among sites and years
# Compile model
compile( "glm_loco.cpp") 

n.y <- dim(loco$C)[1]
n.s <- dim(loco$C)[2] 
# put the data together - note 
Data = list( y = loco$C, X1 = loco$cov1, X2 = loco$cov2, E = loco$effort, n_y = n.y, n_s = n.s)
Parameters = list( beta0 = 1, beta1 = 1, beta2 = 1) #log_sdz_y = 1, log_sdz_s = 1, eps_y = rep(0, n.y ), eps_s = rep(0, n.s ) )

# Build object
dyn.load(dynlib("glm_loco"))
Obj <- MakeADFun(data=Data, parameters=Parameters, DLL = "glm_loco")  

# Prove that function and gradient calls work
Obj$fn( Obj$par )
Obj$gr( Obj$par )

# Optimize
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr )

# Get reporting and SEs
Obj$report()

#compare to the true values
cbind(true = c(loco$alpha, loco$beta1, loco$beta2), glm = Opt$par)



#--------------
#  Fit a GLMM with random effects for year
# --------------

compile( "glmm1_loco.cpp") 

# put the data and parameters together 
Data = list( y = loco$C, X1 = loco$cov1, X2 = loco$cov2, E = loco$effort, n_y = dim(loco$C)[1], n_s = dim(loco$C)[2] )
Parameters2 = list( beta0 = 1, beta1 = 1, beta2 = 1, log_sdz = 1, eps = rep(0, times= n.y ) )

### NEW - specify the random component to the model 
Random = "eps"

# Build object
dyn.load(dynlib("glmm1_loco"))
Obj2 <- MakeADFun(data=Data, parameters=Parameters2, random = Random, DLL = "glmm1_loco")  

# Prove that function and gradient calls work
Obj2$fn( Obj2$par )
Obj2$gr( Obj2$par )

# Optimize
Opt2 = nlminb( start=Obj2$par, objective=Obj2$fn, gradient=Obj2$gr )

#Reporting variables
R2 <- Obj2$report()

#compare to the true values
cbind(true = c(loco$alpha, loco$beta1, loco$beta2, loco$sd.year), glmm1 = c(R2$beta0, R2$beta1, R2$beta2, R2$sdz))


#--------------
#  Fit a GLMM with random effects for site
# --------------

# Steps:
# Use the glmm1_loco.cpp file but change the random effects to be for the site
# Change the Parameters to reflect the site random effects
# Compare the estimates to the true values




#--------------
#  Fit a GLMM with random effects for site and year
# --------------

# Steps:
# Use the glmm1_loco.cpp file but add random effects for the site and the year
# Change the Parameters to reflect the site random effects
# Change the random component to be both year and site random effects
# Compare the estimates to the true values




