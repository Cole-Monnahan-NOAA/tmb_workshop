library(TMB)

## Function and derivative in R
f <- function(x) sum((c(.113, -.24, .583)-x)^2)
fprime <- function(x, h=1e-5) (f(x+h)-f(x))/h
f(1)
fprime(1)

x <- seq(-1,1, len=100)
y <- g <- numeric(length(x))
for(i in 1:length(x)){
  y[i] <- f(x[i])
  g[i] <- fprime(x[i])
}
par(mfrow=c(1,2), tck=-.02, mgp=c(1.5,.25,0), mar=c(3,3,1,.1))
plot(x,y, type='l', lwd=2, main='Height f(x)', ylab='fn')
plot(x,g, type='l', lwd=2, main='Derivative f\'(x)', ylab='gr')
abline(h=0)

## Same function in TMB
compile("TMB_models/simple.cpp")
dyn.load(dynlib("TMB_models/simple"))
obj <- MakeADFun(data=list(), parameters=list(x=1), DLL='simple')
obj$fn(1)  # f(x)
obj$gr(1)  # f'(x)

## optimizers
opt <- nlminb(start=1, objective=f, gradient=fprime)
opt$par
f(opt$par)
fprime(opt$par)

plot(x,y, type='l', lwd=2, main='Height f(x)', ylab='fn')
points(x=opt$par, y=f(opt$par)


## use TMB
opt <- nlminb(obj$par, objective=obj$fn, gradient=obj$gr)
opt$par
obj$fn(opt$par)
obj$gr(opt$par)

## Demo using TMB derivative
compile("TMB_models/polynomial.cpp")
dyn.load(dynlib("TMB_models/polynomial"))
obj <- MakeADFun(data=list(), parameters=list(x=0), DLL='polynomial')
obj$fn(5)
obj$gr(5)

## make plot
x <- seq(-3,2, len=200)
y <- g <- rep(NA, 200)
for(i in 1:length(x)) {
  y[i] <- obj$fn(x[i])
  g[i] <- obj$gr(x[i])
}
#png("polynomial.png", width=5.5, height=2.5, units='in', res=500)
par(mfrow=c(1,2), tck=-.02, mgp=c(1.5,.25,0), mar=c(3,3,1,.1))
plot(x,y, type='l', lwd=2, main='Height f(x)', ylab='fn')
plot(x,g, type='l', lwd=2, main='Derivative f\'(x)', ylab='gr')
abline(h=0)
#dev.off()


