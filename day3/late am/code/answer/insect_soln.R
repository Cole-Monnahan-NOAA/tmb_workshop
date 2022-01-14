#
#SCRIPT FILE TO PLOT FITS TO WASP EGG NUMBER WITH UNCERTAINTY

library(TMB)

#plot the data 
the.data<- dget("day3/insect_data2.txt")
plot(the.data$x, the.data$Y, xlab = "Female Egg Compliment", ylab = "Eggs laid on host", pch = 15)

# compile the TMB model
compile( "tmb_models/insect2.cpp") 

# Build inputs
Data2 = list( y = the.data$Y, x = the.data$x) 
Parameters2 = list( lambda0 = log(2), lambda1 = 1.0 )

#Load the model
dyn.load(dynlib("tmb_models/insect2"))
Obj2 <- MakeADFun(data=Data2, parameters=Parameters2, DLL = "insect2")  

# Optimize
Opt2 = nlminb( start=Obj2$par, objective=Obj2$fn, gradient=Obj2$gr )

# Get reporting and SEs
SD2 = sdreport( Obj2 )

# make a prediction
eggs <- 4:23

TMB2.pred <- exp(Opt2$par[1] + Opt2$par[2]*eggs)
lines(eggs, TMB2.pred, col = 4, lwd = 2)

###--------------------------
###  Exercise - make predictions with uncertainty
###--------------------------


# Modify cpp file to calculate predictions with uncertainty

# run the TMB model
compile( "tmb_models/insect3_soln.cpp") 

# Build inputs
Data = list( y = the.data$Y, x = the.data$x, eggs = eggs) 
Parameters = list( lambda0 = log(2), lambda1 = 1.0 )

dyn.load(dynlib("tmb_models/insect3_soln"))
Obj2 <- MakeADFun(data=Data, parameters=Parameters, DLL = "insect3_soln")  

# Optimize
Opt2 = nlminb( start=Obj2$par, objective=Obj2$fn, gradient=Obj2$gr, control=list("trace"=1) )

# Get reporting and SEs
SD2 = sdreport( Obj )

# make a prediction
lines(eggs, SD2$value, col = 4, lwd = 2)
lines(eggs, SD2$value + 1.96*SD$sd, col = 4, lwd = 2, lty = 2)
lines(eggs, SD2$value - 1.96*SD$sd, col = 4, lwd = 2, lty = 2)



