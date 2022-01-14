# source("insect_jags.r")
#SCRIPT FILE TO RUN THE TWO MODELS FOR INSECT OVIPOSITION
#Noble Hendrix
#noble@qedaconsulting.com


library(TMB)

#plot the data 
the.data<- dget("insect_data2.txt")
plot(the.data$x, the.data$Y, xlab = "Female Egg Compliment", ylab = "Eggs laid on host", pch = 15)

# run the TMB model
compile( "insect1.cpp") 

# Build inputs
Data = list( y = the.data$Y) 
Parameters = list( lambda0 = log(2) )

dyn.load(dynlib("insect1"))
Obj <- MakeADFun(data=Data, parameters=Parameters, DLL = "insect1")  

# Optimize
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr, control=list("trace"=1) )

# Get reporting and SEs
Report = Obj$report()
SD = sdreport( Obj )

# make a prediction
eggs <- 4:23
TMB1.pred <- exp(Opt$par)
lines(eggs, rep(TMB1.pred, times = length(eggs) ), col = 2, lwd = 2)


## second TMB model with an intercept term

# run the TMB model
compile( "insect2.cpp") 

# Build inputs
Data2 = list( y = the.data$Y, x = the.data$x) 
Parameters2 = list( lambda0 = log(2), lambda1 = 1.0 )

dyn.load(dynlib("insect2"))
Obj2 <- MakeADFun(data=Data2, parameters=Parameters2, DLL = "insect2")  

# Optimize
Opt2 = nlminb( start=Obj2$par, objective=Obj2$fn, gradient=Obj2$gr, control=list("trace"=1) )

# Get reporting and SEs
Report2 = Obj2$report()
SD2 = sdreport( Obj2 )

# make a prediction
TMB2.pred <- exp(Opt2$par[1] + Opt2$par[2]*eggs)
lines(eggs, TMB2.pred, col = 4, lwd = 2)

#compare negative log likelihoods
Opt$objective
Opt2$objective


