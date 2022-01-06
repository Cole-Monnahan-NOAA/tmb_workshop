
## Example from the glmmTMB vignette
library("glmmTMB")
library("bbmle") ## for AICtab
## cosmetic
Owls <- transform(Owls,
                  Nest=reorder(Nest,NegPerChick),
                  NCalls=SiblingNegotiation,
                  FT=FoodTreatment)
fit_zipoisson <- glmmTMB(NCalls~(FT+ArrivalTime)*SexParent+
                           offset(log(BroodSize))+(1|Nest),
                         data=Owls,
                         ziformula=~1,
                         family=poisson)
summary(fit_zipoisson)
fit_zinbinom <- update(fit_zipoisson,family=nbinom2)
fit_zinbinom1 <- update(fit_zipoisson,family=nbinom1)
fit_zinbinom1_bs <- update(fit_zinbinom1,
                . ~ (FT+ArrivalTime)*SexParent+ BroodSize+(1|Nest))
AICtab(fit_zipoisson,fit_zinbinom,fit_zinbinom1,fit_zinbinom1_bs)

## Notice the TMB objects and optimizer results are the same
str(fit_zipoisson$obj)
str(fit_zipoisson$fit)


## demo example of sdmTMB
library(dplyr)
library(ggplot2)
library(sdmTMB)
head(pcod)
mesh <- make_mesh(pcod, xy_cols = c("X", "Y"), cutoff = 10)
fit <- sdmTMB(
  density ~ s(depth, k = 5),
  data = pcod,
  mesh = mesh,
  family = tweedie(link = "log"),
  spatial = "on"
)
summary(fit)
plot_smooth(fit, ggplot = TRUE)
p <- predict(fit, newdata = qcs_grid)
ggplot(p, aes(X, Y, fill = exp(est))) + geom_raster() +
  scale_fill_viridis_c(trans = "sqrt")

p_st <- predict(fit_spatiotemporal, newdata = qcs_grid,
  return_tmb_object = TRUE, area = 4)
index <- get_index(p_st)
ggplot(index, aes(year, est)) +
  geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "grey90") +
  geom_line(lwd = 1, colour = "grey30") +
  labs(x = "Year", y = "Biomass (kg)")






#### VAST example from wiki: index standardization
##https://github.com/James-Thorson-NOAA/VAST/wiki/Index-standardization
# Load package
library(VAST)

# load data set
# see `?load_example` for list of stocks with example data
# that are installed automatically with `FishStatsUtils`.
example = load_example( data_set="EBS_pollock" )

# Make settings (turning off bias.correct to save time for example)
settings = make_settings( n_x = 100,
  Region = example$Region,
  purpose = "index2",
  bias.correct = FALSE )

# Run model
fit = fit_model( settings = settings,
  Lat_i = example$sampling_data[,'Lat'],
  Lon_i = example$sampling_data[,'Lon'],
  t_i = example$sampling_data[,'Year'],
  b_i = example$sampling_data[,'Catch_KG'],
  a_i = example$sampling_data[,'AreaSwept_km2'] )

# Plot results
plot( fit )


### Quick demo of MCMC sampling with Stan
library(tmbstan)
compile("TMB_models/simple.cpp")
dyn.load(dynlib("TMB_models/simple"))
obj <- MakeADFun(data=list(), parameters=list(x=1), DLL='simple')

mcmc <- tmbstan(obj, chains=4, cores=1)
mcmc ## summary
str(as.data.frame(mcmc)) ## posterior samples

## Simulation. See more examples at
## http://kaskr.github.io/adcomp/_book/Simulation.html
compile("tmb_models/linmod_simulator.cpp")
dyn.load(dynlib("tmb_models/linmod_simulator"))
set.seed(231)
x <- rnorm(50)
y <- 3-1.5*x+rnorm(50, sd=exp(.1))
obj <- MakeADFun(data=list(x=x,y=y),
                 parameters=list(intercept=-5, slope=1, logsd=0),
                 DLL='linmod_simulator', silent=TRUE)
## This uses C++ to simulate new data y, given the current parameters
obj$simulate() # before optimizing
opt <- nlminb(obj$par, obj$fn, obj$gr)
obj$simulate() # after
