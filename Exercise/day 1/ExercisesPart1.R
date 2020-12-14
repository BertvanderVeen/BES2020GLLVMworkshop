# ---
# title: "Exercises Part 1"
# author: Jenni Niku, University of Jyväskylä,  [jenni.m.e.niku@jyu.fi]
# date: "12/16/2020"
# ---

# Introduction to gllvm

## R package gllvm
# - **R** package **gllvm** fits Generalized linear latent variable models (GLLVM) for multivariate data^[Niku, J., F.K.C. Hui, S. Taskinen, and D.I. Warton. 2019. Gllvm - Fast Analysis of Multivariate Abundance Data with Generalized Linear Latent Variable Models in R. 10. Methods in Ecology and Evolution: 2173–82].
# - Developed by J. Niku, W.Brooks, R. Herliansyah, F.K.C. Hui, S. Taskinen, D.I. Warton, B. van der Veen.
# - Version 1.2.3 now available in
#    - GitHub: <https://github.com/JenniNiku/gllvm> 
#    - CRAN: <https://cran.r-project.org/web/packages/gllvm/index.html>

# Package installation:
# From CRAN
install.packages(gllvm)
# OR
# From GitHub using devtools package's function install_github
devtools::install_github("JenniNiku/gllvm")
# gllvm package depends on R packages **TMB** and **mvabund**, try to install these first if you encounter problems.

# load package:
library(gllvm)

## Spider data:
# - Abundances of 12 hunting spider species measured as a count at 28 sites^[van der Aart, P. J. M., and Smeenk-Enserink, N. (1975) Correlations between distributions of hunting spiders (Lycosidae, Ctenidae) and environmental characteristics in a dune area. Netherlands Journal of Zoology 25, 1-45.].
# - Six environmental variables measured at each site.
#    * `soil.dry`: Soil dry mass
#    * `bare.sand`: cover of bare sand
#    * `fallen.leaves`: cover of fallen leaves/twigs
#    * `moss`: cover of moss
#    * `herb.layer`: cover of herb layer
#    * `reflection`: reflection of the soil surface with a cloudless sky


# Exercises
# NOTE: Answers with results are also here: https://jenniniku.github.io/gllvm/articles/vignette3.html#exercises-1

### E1. Load spider data from **mvabund** package and take a look at the dataset.

#Package **mvabund** is loaded with **gllvm** so just load with a function `data()`.
data("spider")
# more info: 
?spider

# Print the data and covariates and draw a boxplot of the data. 
# response matrix:
spider$abund
# Environmental variables
spider$x
# Plot data using boxplot:
boxplot(spider$abund)




### E2. Fit GLLVM to spider data with a suitable distribution. Data consists of counts of spider species.
# Take a look at the function documentation for help: 
?gllvm

# Response variables in spider data are counts, so Poisson, negative binomial 
# and zero inflated Poisson are possible. However, ZIP is implemented only 
# with Laplace method, so it need to be noticed, that if models are fitted 
# with different methods they can not be compared with information criterias. 
# Let's try just with a Poisson and NB.
# NOTE THAT the results may not be exactly the same as below, as the initial values for each model fit are slightly different, so the results may also differ slightly.
# Fit a GLLVM to data
fitp <- gllvm(y=spider$abund, family = poisson())
fitp
fitnb <- gllvm(y=spider$abund, family = "negative.binomial")
fitnb

# Based on AIC, NB distribution suits better. How about residual analysis:
# NOTE THAT The package uses randomized quantile residuals so each time you plot the residuals, they look a little different.
# Fit a GLLVM to data
plot(fitp)
plot(fitnb)

# You could do these comparisons with Laplace method as well, using the code below, and it would give the same conclusion that NB distribution suits best:
# fitLAp <- gllvm(y=spider$abund, family = poisson(), method = "LA", seed = 123)
# fitLAnb <- gllvm(y=spider$abund, family = "negative.binomial", method = "LA", seed = 123)
# fitLAzip <- gllvm(y=spider$abund, family = "ZIP", method = "LA", seed = 123)
# AIC(fitLAp)
# [1] 1761.371
# AIC(fitLAnb)
# [1] 1506.862
# AIC(fitLAzip)
# [1] 1795.768
# plot(fitLAp, which = 1:2)
# plot(fitLAnb, which = 1:2)
# plot(fitLAzip, which = 1:2)




### E3. Explore the fitted model. Where are the estimates for parameters? What about predicted latent variables? Standard errors?

# Lets explore the fitted model: 
# Parameters:
coef(fitnb)
# Where are the predicted latent variable values? just fitp$lvs or
getLV(fitnb)
# Standard errors for parameters:
fitnb$sd



### E4. Fit model with different numbers of latent variables.

# Default number of latent variables is 2. Let's try 1 and 3 latent variables as well:
# In exercise 2, we fitted GLLVM with two latent variables 
fitnb
# How about 1 or 3 LVs
fitnb1 <- gllvm(y=spider$abund, family = "negative.binomial", num.lv = 1)
fitnb1
getLV(fitnb1)
fitnb3 <- gllvm(y=spider$abund, family = "negative.binomial", num.lv = 3)
fitnb3
getLV(fitnb3)




### E5. Include environmental variables to the GLLVM and explore the model fit.

# Environmental variables can be included with an argument `X`: 
fitnbx <- gllvm(y = spider$abund, X = spider$x, family = "negative.binomial", seed = 123)
fitnbx
coef(fitnbx)
# confidence intervals for parameters:
confint(fitnbx)



#######################################################
# Problems? See hints:
# I have problems in model fitting. My model converges to infinity or local maxima: </span> 
# GLLVMs are complex models where starting values have a big role. Choosing a different starting value method (see argument `starting.val`) or use multiple runs and pick up the one giving highest log-likelihood value using argument `n.init`. More variation to the starting points can be added with `jitter.var`.

# My results does not look the same as in answers:
# The results may not be exactly the same as in the answers, as the initial values for each model fit are slightly different, so the results may also differ slightly.

