# *Fitting hierarchical models in Template Model Builder*

Course materials for a virtual TMB workshop at the Universidad de Concepción,
January 2022.


Tenative syllabus:

|    <br>     |    <br>Topic    |    <br>Morning Topic (Theory and   Mechanisms)<br>   <br>1.5 hour<br>   <br>10am-11:30 CST<br>   <br>5am-6:30am PST<br>   <br>Definitely recorded    |    <br>Late Morning - Case-Studies / Projects   1 hour [C&N]<br>   <br>12-1pm CST<br>   <br>7-8am PST<br>   <br>Potentially recorded    |    <br>Afternoon Lab<br>   <br>3 hours [C&N]<br>   <br>2-5pm CST<br>   <br>9-12pm PST<br>   <br>Live –virtual    |
|---|---|---|---|---|
|    <br>Monday    |    <br>Course introduction; Review model fitting; introduce TMB    |    <br>Numerical optimization using derivatives; Finite differences vs   autodiff; Refresher on Rstudio & R. [Cole]    |    <br>Maximum likelihood of single parameter Normal model (Excel and R)   [Cole]<br>   <br>     |    <br>Poisson model<br>   <br>Project time: proposals and scope    |
|    <br>Tuesday    |    <br>Building linear models in TMB    |    <br>TMB/C++ syntax, workflow, factors, debugging, factors in TMB [Cole]    |    <br>Maximum likelihood estimation; Fit LM in R by hand, using lm() and in   TMB [Cole]    |    <br>Exploring Beverton-Holt TMB model<br>   <br>     |
|    <br>Wednesday    |    <br>GLMs    |    <br>GLM theory [To   do] [Noble]    |    <br>Estimating uncertainty: standard errors, Delta method [Noble]<br>   <br>likelihood profile, bootstrapping <br>   <br>     |    <br>Poisson GLM<br>   <br>Project time    |
|    <br>Thursday    |    <br>Random effects in TMB     |    <br>Types of mixed effects models; Marginal maximum likelihood [Noble]    |    <br>Project time    |    <br>VBG for pooled samples and individual ones;<br>   <br>Hierarchical VBG; <br>   <br>     |
|    <br>Friday    |    <br>Beyond GLMMs    |    <br>Advanced TMB features: mapping, REML, simulation, functions <br> sdmTMB and   glmmTMB? [To do] [Cole?]    |    <br>Project time    |    <br>Project presentations    |



Some material was modified with permission from a course by Jim Thorson at
https://github.com/James-Thorson/2016_Spatio-temporal_models. 



 

## Ideas for next time

#### Data sets

* Just have one data set that we keep analyzing over and over
  * Has fixed effects
  * Has random effects
  * Has a slope
* First day - Start with just a mean and normal likelihood
* Second day - add the slope
* Third day - add random effects and fit with LME
* Fourth day - add GLM 

#### Advantages of recording

* Was good for presenting ideas and could be used in the future 

#### Uses of channels

* Could create multiple rooms for groups of 2 
* Use them in the labs so that 2 students can share a room
* Professores can move among rooms and check in on the students working on the labs and projects

#### Topics on which to focus an entire class

* CPUE analysis 
* glmmTMB and sdmTMB?

