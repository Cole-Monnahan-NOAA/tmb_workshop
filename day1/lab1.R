

## Step 1: plot f(x)
f <- function(x) 2*x-4*log(x)-5*log(x)
x <- seq(1,10, len=50)
plot(x,f(x), type='b')

fprime <- function(x) (f(x+.001)-f(x))/.001
plot(x,fprime(x), type='b')

library(TMB)
compile('tmb_models/lab1.cpp')
dyn.load(dynlib('tmb_models/lab1'))
obj <- MakeADFun(data=list(), parameters=list(x=5), DLL='lab1')
opt <- nlminb(obj$par, obj$fn, obj$gr)
opt$par


## 2D function
f <- function(x) x[1]-7*log(x[1])+x[2]-8*log(x[2])
opt <- nlminb(c(1,1), f)
opt$par
f(opt$par)
x1 <- x2 <- seq(2,15, len=100)
x <- expand.grid(x1,x2)
z <- apply(x, 1,f)
z1 <- matrix(z, nrow=100, ncol=100, byrow=FALSE)
contour(x1,x2,z1, nlevels=30)
points(x=opt$par[1], y=opt$par[2], col='red', pch=16)
