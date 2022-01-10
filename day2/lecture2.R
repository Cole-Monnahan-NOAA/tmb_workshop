## Lecture 2 code

## Variable types in R
x <- list(a=5L, b=5, c=rnorm(5), d='hello',
          e=factor(c('low', 'high')))
str(x)

## Probability of coin flips
p <- 0.5
x <- 0:50
probability <- choose(50,x)*p^x*(1-p)^(50-x)
sum(probability)
plot(x, probability, type='b')

## Likelihood of coin flips
p <- seq(0,1, len=50)
likelihood <- choose(50,45)*p^45*(1-p)^5
plot(p, likelihood, type='b')


(.9^45*(1-.9)^5)/(.5^45*(1-.5)^5)

## Part 2: Fitting linear model: y=a+b*x
x <- c(1.87, 1.96, 1.39, 2.24, 2.33, 2.24, 2.67, 2.47, 1.35, 2.00)
y <- c(2.47, 2.42, 2.2, 2.72, 2.65, 2.5, 2.85, 2.77, 2.28, 2.45)
plot(x,y)

## Use the built-in lm function
fit1 <- lm(y~x)
abline(fit1, lwd=2)
coef(fit1)

## Manual NLL function
nll <- function(pars){
  ## Extract parameters from vector
  intercept <- pars[1]
  slope <- pars[2]
  sd <- exp(pars[3])
  ## Predict y given parameters
  mu <- intercept + slope*x
  ## Calculate log likelihood by hand
  nll <- -sum(dnorm(y, mu, sd, log=TRUE))
  return(nll)
}

## Third way is to use TMB to calculate likelihood
compile("tmb_models/linmod.cpp")
dyn.load(dynlib("TMB_models/linmod"))
obj <- MakeADFun(data=list(x=x,y=y),
                 parameters=list(intercept=1, slope=0.5, logsd=-2),
                 DLL='linmod')

## Check that all three ways matches other ways
pars <- c(1.2, 0.6, -2)
nll(pars)
obj$fn(pars)
## TMB also provides gradient using automatic differentiation
obj$gr(pars)
fit.R <- nlminb(start=pars, objective=nll)
fit.tmb <- nlminb(start=pars, objective=obj$fn, gradient=obj$gr)
coef(fit1)
(mle <- fit.R$par)
## Should be close to zero:
obj$gr(fit.tmb$par)

## Show the improvement in NLL from intitial to MLE
obj$fn(pars)
obj$fn(mle)
plot(x,y)
abline(a=pars[1], b=pars[2], col='blue', lty=2, lwd=2)
abline(a=mle[1], b=mle[2], col='red', lty=3, lwd=2)

## What about the variance estimate?
summary(lm(y~x))
exp(fit.tmb$par[3])
## The sigma parameters do not match because lm() uses REML. We can
## recreate that by integrating out the other fixed effects except the
## variance term.
obj <- MakeADFun(data=list(x=x,y=y), random=c("intercept", "slope"),
                 parameters=list(intercept=1, slope=0.5, logsd=-2),
                 DLL='linmod')
test <- nlminb(start=-2, obj$fn)
exp(test$par)
