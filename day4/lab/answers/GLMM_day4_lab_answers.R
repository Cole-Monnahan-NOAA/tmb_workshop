# ****************************
### Answers to Lab4 GLMM
# ***************************


#--------------
#  Fit a GLMM with random effects for site
# --------------

compile( "tmb_models/glmm2_loco.cpp") 

# put the data and parameters together 
Data = list( y = loco$C, X1 = loco$cov1, X2 = loco$cov2, E = loco$effort, n_y = dim(loco$C)[1], n_s = dim(loco$C)[2] )
Parameters3 = list( beta0 = 1, beta1 = 1, beta2 = 1, log_sdz = 1, eps = rep(0, times= n.s ) )

### NEW - specify the random component to the model 
Random = "eps"

# Build object
dyn.load(dynlib("tmb_models/glmm2_loco"))
Obj3 <- MakeADFun(data=Data, parameters=Parameters3, random = Random, DLL = "glmm2_loco")  

# Prove that function and gradient calls work
Obj3$fn( Obj3$par )
Obj3$gr( Obj3$par )

# Optimize
Opt3 = nlminb( start=Obj3$par, objective=Obj3$fn, gradient=Obj3$gr )

#Reporting variables
R3 <- Obj3$report()

#compare to the true values
cbind(true = c(loco$alpha, loco$beta1, loco$beta2, loco$sd.site), glmm1 = c(R3$beta0, R3$beta1, R3$beta2, R3$sdz))

#--------------
#  Fit a GLMM with random effects for site and year
# -------------

compile( "tmb_models/glmm3_loco.cpp") 

# Build inputs
Data = list( y = loco$C, X1 = loco$cov1, X2 = loco$cov2, E = loco$effort, n_y = n.y, n_s = n.s )

# Note these need to be in the same order as in the template file
Parameters4 = list(  beta0 = 1, beta1 = 1, beta2 = 1, log_sdz_s = 1, log_sdz_y = 1, eps_s = rep(0, n.s ), eps_y = rep(0, n.y ) )
Random = c("eps_s", "eps_y")

# Build object
dyn.load(dynlib("tmb_models/glmm3_loco"))
Obj4 <- MakeADFun(data=Data, parameters=Parameters4, random = Random, DLL = "glmm5")  

# Prove that function and gradient calls work
Obj4$fn( Obj4$par )
Obj4$gr( Obj4$par )

# Optimize
Opt4 = nlminb( start=Obj4$par, objective=Obj4$fn, gradient=Obj4$gr)


# Get reporting and SEs
R4 = Obj4$report()

#compare to the true values
cbind(true = c(loco$alpha, loco$beta1, loco$beta2, loco$sd.site, loco$sd.year), glmm3 = c(R4$beta0, R4$beta1, R4$beta2, R4$sdz_s, R4$sdz_y))

