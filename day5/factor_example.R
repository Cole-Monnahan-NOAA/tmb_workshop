## Lecture 2.3 code
library(TMB)
library(ggplot2)

## Simulate Poisson example
set.seed(343)
## true hyperdistribution
mu <- 40
sigma <- 10
n.sites <- 10
## Simulate random densities at sites
D <- round(rnorm(n.sites, mu, sigma),2)
sites <- as.factor(rep(LETTERS[1:n.sites], each=5))
C <- rpois(length(sites), D[sites])
boxplot(C~sites)

D[sites]

ord <- sample(1:length(C), size=length(C), replace=FALSE)
C <- C[ord]
sites <- sites[ord]


-sum(dpois(x=C, lambda=D[sites], log=TRUE))

compile("tmb_models/poisson.cpp")
dyn.load(dynlib("tmb_models/poisson"))
data <- list(C=C, sites=sites)
pars <- list(D=D, mu=20, logsigma=100)
obj <- MakeADFun(data=data, parameters=pars, random='D', DLL='poisson')
obj$report()
opt <- with(obj, nlminb(par, fn, gr))
opt$par
