## script to simulate data for use in a TMB regression with random effects

n.obs <- 120

b0 <- 0.5
b1 <- 1.2
x <- rnorm(n.obs)
true.val <- b0 + b1*x

## random effects
n.groups <- 5  # number of random effect groups (e.g., barcos)
sd.random <- 0.5  # standard deviation of random effect
re.val<- rnorm(n.groups, mean = 0, sd = sd.random)
re.vector <- sample.int(n = n.groups, size = n.obs, replace = TRUE)  # group number (e.g., numero de barco )

ex.y <- b0 + b1*x + re.val[re.vector]

value.y <- rnorm(n.obs, mean = ex.y, sd = 1 )

#show the data by group
library(lattice) 
xyplot(value.y~x|re.vector, xlab = "X values", ylab = "Y values")


re.factor <- factor(re.vector)

### Fit model in TMB
library(TMB)

compile( "tmb_models/lmm_factor.cpp") 

# put the data and parameters together 
Data = list( y = value.y, X = x, R = re.factor, n_g = n.groups) 
Parameters = list( beta0 = 1, beta1 = 1, logsigma = 1, logsd = 1, eps = rep(0, times= n.groups ) )
Random = "eps"

# Build object
dyn.load(dynlib("tmb_models/lmm_factor"))
Obj <- MakeADFun(data=Data, parameters=Parameters, random = Random, DLL = "lmm_factor")  

# Prove that function and gradient calls work
Obj$fn( Obj$par )
Obj$gr( Obj$par )

# Optimize
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr )

#Reporting variables
rep <- Obj$report()


