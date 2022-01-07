
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


