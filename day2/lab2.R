#### Linear models with TMB
library(TMB)

## We will simulate a data set
set.seed(121431)
N <- 200
beta0 <- 1
beta1 <- -1.5
beta2 <- 3.5
sigma <- 0.25
## Simulate covariate values
x1 <- rnorm(N,mean=5, sd=2)
x2 <- rnorm(N,mean=-2, sd=1)
## Calculate observed values
eps <- rnorm(N,0,sd=sigma)
y <- beta0 + x1*beta1 + x2*beta2 + eps

## Plot them
par(mfrow=c(1,2))
plot(x1,y)
plot(x2,y)


## Fit it in TMB
compile('tmb_models/lab2.cpp')
dyn.load(dynlib('tmb_models/lab2'))
obj <- MakeADFun(data=list(x1=x1, x2=x2, y=y),
                 ## Initial values
                 parameters=list(beta0=0, beta1=0, beta2=2),
                 DLL='lab2')
obj$fn()
obj$gr()
opt <- nlminb(obj$par, obj$fn, obj$gr)
opt$par


## Add estimation of sigma
compile('tmb_models/lab2a.cpp')
dyn.load(dynlib('tmb_models/lab2a'))
obj2a <- MakeADFun(data=list(x1=x1, x2=x2, y=y),
                 ## Initial values
                 parameters=list(beta0=0, beta1=0, beta2=2, logsigma=0),
                 DLL='lab2a')
obj2a$fn()
obj2a$gr()
opt2a <- nlminb(obj2a$par, obj2a$fn, obj2a$gr)
opt2a$par
obj2a$report(opt2a$par)


## simulation test
compile('tmb_models/lab2a.cpp')
dyn.load(dynlib('tmb_models/lab2a'))

Nsim <- 5000
## Empty matrix to store results
mles <- matrix(data=NA, nrow=Nsim, ncol=4)
for(i in 1:Nsim){
  set.seed(i)
  eps <- rnorm(N,0,sd=sigma)
  y <- beta0 + x1*beta1 + x2*beta2 + eps
  ## rebuild the obj each time we change data
  obj2a <- MakeADFun(data=list(x1=x1, x2=x2, y=y),
                     ## Initial values
                     parameters=list(beta0=0, beta1=0, beta2=2, logsigma=0),
                     DLL='lab2a', silent=TRUE)
  opt2a <- nlminb(obj2a$par, obj2a$fn, obj2a$gr)
  mles[i,] <- opt2a$par
}
## convert logsigma to sigma
mles[,4] <- exp(mles[,4])
mles <- as.data.frame(mles)
names(mles) <- c('beta0', 'beta1', 'beta2','sigma')
## look at relative differences
mles[,1] <- (mles[,1]-beta0)/beta0
mles[,2] <- (mles[,2]-beta1)/beta1
mles[,3] <- (mles[,3]-beta2)/beta2
mles[,4] <- (mles[,4]-sigma)/sigma
boxplot(mles, ylab='Relative error')
abline(h=0, col='red')

