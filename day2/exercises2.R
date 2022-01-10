library(TMB)
flags <- "-Wno-ignored-attributes -O2 -mfpmath=sse -msse2 -mstackrealign"
## flags <- ""

## Exercise: Add logsigma as parameter
dat <- read.table("tmb_models/bevholt.dat", header=TRUE)
plot(dat$ssb, exp(dat$logR))

compile("tmb_models/bevholt.cpp", flags=flags)
dyn.load(dynlib("tmb_models/bevholt"))
obj <- MakeADFun(data=list(SSB=dat$ssb,logR=dat$logR),
                 parameters=list(logA=0, logB=1),
                 DLL="bevholt", silent=TRUE)
opt <- with(obj, nlminb(par, fn, gr))
str(opt)

## Now add sigma as an estimated parameter
compile("tmb_models/bevholt2.cpp", flags=flags)
dyn.load(dynlib("tmb_models/bevholt2"))
obj <- MakeADFun(data=list(SSB=dat$ssb,logR=dat$logR),
                 parameters=list(logA=0, logB=1, logsigma=0.5),
                 DLL="bevholt2", silent=TRUE)
opt <- with(obj, nlminb(par, fn, gr))
str(opt)
obj$gr(opt$par)

## Now vectorize and add REPORT
compile("tmb_models/bevholt3.cpp", flags=flags)
dyn.load(dynlib("tmb_models/bevholt3"))
obj <- MakeADFun(data=list(SSB=dat$ssb,logR=dat$logR),
                 parameters=list(logA=0, logB=1, logsigma=0.5),
                 DLL="bevholt3", silent=TRUE)
opt <- with(obj, nlminb(par, fn, gr))
str(opt)
obj$gr(opt$par)

## now we have REPORT 
obj$report(opt$par)

## Poisson likelihood by hand
## pmf=exp(-lambda)*lambda^k/k!
k <- 4
lambda <- 5.5
nll <- function(lambda) -log(exp(-lambda)*lambda^k/factorial(k))
nll(5.5)
-dpois(k, lambda, log=TRUE)

lambda <- seq(0,15, len=50)
plot(lambda, nll(lambda))

opt <- nlminb(start=10, nll)
opt$par                                # value that gives minimum
opt$objective                          # the minimum


