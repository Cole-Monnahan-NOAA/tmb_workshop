# source("insect_TMB_pred.r")
#SCRIPT FILE TO PLOT FITS TO WASP EGG NUMBER WITH UNCERTAINTY
#Noble Hendrix
#noble@qedaconsulting.com


library(TMB)

#plot the data 
the.data<- dget("insect_data2.txt")
plot(the.data$x, the.data$Y, xlab = "Female Egg Compliment", ylab = "Eggs laid on host", pch = 15)

eggs <- 4:23

# run the TMB model
compile( "insect2_pred.cpp") 

# Build inputs
Data = list( y = the.data$Y, x = the.data$x, eggs = eggs) 
Parameters = list( lambda0 = log(2), lambda1 = 1.0 )

dyn.load(dynlib("insect2_pred"))
Obj <- MakeADFun(data=Data, parameters=Parameters, DLL = "insect2_pred")  

# Optimize
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr, control=list("trace"=1) )

# Get reporting and SEs
SD = sdreport( Obj )

# make a prediction
lines(eggs, SD$value, col = 4, lwd = 2)
lines(eggs, SD$value + 1.96*SD$sd, col = 4, lwd = 2, lty = 2)
lines(eggs, SD$value - 1.96*SD$sd, col = 4, lwd = 2, lty = 2)

