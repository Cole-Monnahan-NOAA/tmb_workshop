
#.  Code adopted from - 
#    Mixed Effects Models and Extensions in Ecology with R (2009)
#    Zuur, Ieno, Walker, Saveliev and Smith.    Springer
#    This file was produced by Alain Zuur (highstat@highstat.com)
#    www.highstat.com


#Poisson and negative binomial modeling of road kill data

#Roadkill data

RK <- read.table("RoadKills.txt", header = TRUE) 

plot(RK$D.PARK,RK$TOT.N,xlab="Distance to park",
     ylab="Road kills")

# Fit the model in R
M1<-glm(TOT.N~D.PARK,family=poisson,data=RK)
summary(M1)

#TMB Model for distance to park - 

library(TMB)

# Compile model
compile( "glm1.cpp") 
dyn.load(dynlib("glm1"))
# Build inputs
Data = list( y = RK$TOT.N, X = RK$D.PARK)
Parameters = list( beta0 = 5, beta1 = - 0.0005)

# Build object
#dyn.load( dynlib(Version) )
Obj <- MakeADFun(Data, Parameters, DLL = "glm1")  

# Prove that function and gradient calls work
Obj$fn( Obj$par )
Obj$gr( Obj$par )

# Optimize
start_time = Sys.time()
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr)

# Can calculate a couple useful bits here: 
Opt[["final_gradient"]] = Obj$gr( Opt$par )
Opt[["total_time"]] = Sys.time() - start_time

# Get SEs
SD = sdreport( Obj )

#compare results in R to TMB
cbind(summary(M1)$coefficients[,1:2], TMB.coef= Opt$par, TMB.sd = SD$sd)

# ---------------------------------------
# try model with centering the covariate
Dist.Cent <- (RK$D.PARK - mean(RK$D.PARK) )/sd(RK$D.PARK)

# quick plot of the centered data

plot(Dist.Cent,RK$TOT.N,xlab="Centered distance to park",
     ylab="Road kills")

###
#R model
M1.1<-glm(RK$TOT.N~Dist.Cent,family=poisson,data=RK)
summary(M1.1)

####
#  TMB model

# Compile model - Not needed since already compiled!
#compile( "glm1.cpp") 
#dyn.load(dynlib("glm1"))
# Build inputs
Data = list( y = RK$TOT.N, X = Dist.Cent)
Parameters = list( beta0 = 5, beta1 = - 0.5)

# Build object
#dyn.load( dynlib(Version) )
Obj1 <- MakeADFun(Data, Parameters, DLL = "glm1")  

# Prove that function and gradient calls work
Obj1$fn( Obj1$par )
Obj1$gr( Obj1$par )

# Optimize
start_time = Sys.time()
Opt1 = nlminb( start=Obj1$par, objective=Obj1$fn, gradient=Obj1$gr, control=list("trace"=1) )
Opt1[["final_gradient"]] = Obj1$gr( Opt1$par )
Opt1[["total_time"]] = Sys.time() - start_time

# Get reporting and SEs
#Report1 = Obj1$report()
SD1 = sdreport( Obj1 )


#compare results in R to TMB
cbind(summary(M1.1)$coefficients[,1:2], TMB.coef= SD1$value, TMB.sd = SD1$sd)


# ------------------------
# Fit a GLM with more covariates -
#  use the centered distance covariate

# want to center several additional covariates 
# can use scale() function in R rather than equation on line 57
# scale also works for matrices

#scale entire matrix except for TOT.N, the counts 
RK.C <- data.frame( scale(RK[,-5]) )
# add the counts back to the dataframe
RK.C$TOT.N <- RK$TOT.N


# fit a subset of the covariates
M2<-glm(TOT.N~ S.RICH + OPEN.L + MONT.S + OLIVE + POLIC + MONT.S +
          SHRUB  + L.WAT.C+ L.P.ROAD +
         D.WAT.RES + D.PARK ,family=poisson,data=RK.C)

summary(M2)

# drop each element of the full model one at a time 
# and calculate a ChiSq test on the deviance change
drop1(M2,test="Chi")

#retain the significant covariates
M3 <- glm(TOT.N ~ S.RICH + MONT.S + SHRUB + L.WAT.C + 
            L.P.ROAD + D.WAT.RES + D.PARK, family = poisson, data = RK.C)
anova(M2, M3, test = "Chi")

# Fit model M3 in TMB
# Want to construct a TMB model that uses matrix multiplication
# 1. Begin with glm_start.cpp and we will step through it, you will need to
# 2. Modify this file to include (hint: see day 2 lecture building TMB models)
#      a) the matrix of covariates, X
#      b) the parameters beta
# 3. Save "as glm_mat.cpp"

#TMB model with multiple covariates
compile( "glm_mat.cpp") 
dyn.load(dynlib("glm_mat"))
# Build inputs
n.y<- length(RK.C$TOT.N)
X.mat <- cbind( rep(1, n.y), RK.C$S.RICH, RK.C$MONT.S, RK.C$SHRUB, RK.C$L.WAT.C, RK.C$L.P.ROAD, RK.C$D.WAT.RES, RK.C$D.PARK ) 
Data = list( y = RK.C$TOT.N, X = X.mat )
Parameters = list( beta = c(4, rep(0, times = dim(X.mat)[2]-1 ) ) )
 
# Build object
#dyn.load( dynlib(Version) )
Obj.M3 <- MakeADFun(Data, Parameters, DLL = "glm_mat")  

# Prove that function and gradient calls work
Obj.M3$fn( Obj.M3$par )
Obj.M3$gr( Obj.M3$par )

# Optimize
start_time = Sys.time()
Opt.M3 = nlminb( start=Obj.M3$par, objective=Obj.M3$fn, gradient=Obj.M3$gr )
Opt.M3[["final_gradient"]] = Obj.M3$gr( Opt.M3$par )
Opt.M3[["total_time"]] = Sys.time() - start_time

# Get reporting and SEs
SD.M3 = sdreport( Obj.M3 )

#compare estimates between R and TMB
cbind(summary(M3)$coefficients[,1:2], TMB.coef= SD.M3$value, TMB.sd = SD.M3$sd)


### Negative Binomial ###

## simulate some negative binomial random variables in R
set.seed(12345)

pois.y <- rpois(300, 2.7)  #var = 2.7
negbin.y <- rnbinom(300, mu = 2.7, size = 1.0)# var = 2.7 + 2.7^2 = 9.99

hist(negbin.y, border = 2, col = "pink")
hist(pois.y,  add = TRUE)

compile( "nb.cpp") 
dyn.load(dynlib("nb"))
# Build inputs
Data = list( y = negbin.y)
Parameters = list( logmu = log(2.0), logtheta = log(6))

# Build object
#dyn.load( dynlib(Version) )
Obj4 <- MakeADFun(Data, Parameters, DLL = "nb")  

# Prove that function and gradient calls work
Obj4$fn( Obj$par )
Obj4$gr( Obj$par )

# Optimize
Opt4 = nlminb( start=Obj4$par, objective=Obj4$fn, gradient=Obj4$gr)

exp(Opt4$par)

## Now, let's try the poisson data
Data = list( y = pois.y)
Parameters = list( logmu = log(2.0), logtheta = log(6))
# Build object
#dyn.load( dynlib(Version) )
Obj5 <- MakeADFun(Data, Parameters, DLL = "nb")  

# Prove that function and gradient calls work
Obj5$fn( Obj$par )
Obj5$gr( Obj$par )

# Optimize
Opt5 = nlminb( start=Obj5$par, objective=Obj5$fn, gradient=Obj5$gr)
exp(Opt5$par)


### Final Exercise 
## -----------------------------
# Modify the glm_mat.cpp TMB code to use a negative binomial rather than a Poisson likelihood for the data

# Step 1 - add logtheta as parameter
# Step 2 - transform logtheta
# Step 3 -  change the likelihood from dpois to dnbinom2 and include theta as a parameter 
# Step 4 - save as "glmb_nb.cpp"
## -----------------------------

# Now let's run the TMB model
compile( "glm_nb.cpp") 
dyn.load(dynlib("glm_nb"))
# Build inputs
Data = list( y = RK.C$TOT.N, X = X.mat )
Parameters = list( beta = c(4, rep(0, times = dim(X.mat)[2]-1 ) ),  logtheta = log(100))

# Build object
#dyn.load( dynlib(Version) )
Obj6 <- MakeADFun(Data, Parameters, DLL = "glm_nb")  

Opt6 = nlminb( start=Obj6$par, objective=Obj6$fn, gradient=Obj6$gr)
SD.6 = sdreport( Obj6 )

cbind(TMB_P.coef= SD.M3$value, TMB_P.sd = SD.M3$sd, TMB_NB.coef = SD.6$value, TMB_NB.sd = SD.6$sd)