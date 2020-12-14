# ---
# title: "Exercises Part 1"
# author: Jenni Niku, University of Jyväskylä,  [jenni.m.e.niku@jyu.fi]
# date: "12/16/2020"
# ---

# Introduction to gllvm

## R package gllvm
# - **R** package **gllvm** fits Generalized linear latent variable models (GLLVM) for multivariate data^[Niku, J., F.K.C. Hui, S. Taskinen, and D.I. Warton. 2019. Gllvm - Fast Analysis of Multivariate Abundance Data with Generalized Linear Latent Variable Models in R. 10. Methods in Ecology and Evolution: 2173-82].
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
# NOTE: Answers with results are also here: https://jenniniku.github.io/gllvm/articles/vignette4.html#exercises-1


### E1. Load spider data from **mvabund** package and take a look at the dataset.  

#Package **mvabund** is loaded with **gllvm** so just load with a function `data()`.
data("spider")
# more info: 
?spider

# Package **mvabund** is loaded with **gllvm** so just load with a function `data()`.  
# response matrix:
spider$abund
# Environmental variables
spider$x
# Plot data using boxplot:
boxplot(spider$abund)



### E2. Fit GLLVM with two latent variables to spider data with a suitable distribution. Data consists of counts of spider species. 
# Take a look at the function documentation for help: 
?gllvm

# Response variables in spider data are counts, so Poisson, negative binomial 
# and zero inflated Poisson are possible. However, ZIP is implemented only with 
# Laplace method, so it need to be noticed, that if models are fitted with 
# different methods they can not be compared with information criterias. 
# Let's try just with a Poisson and NB.  
# NOTE THAT: The results may not be exactly the same as below, as the initial values for each model fit are slightly different, so the results may 
# Fit a GLLVM to data
fitp <- gllvm(y=spider$abund, family = poisson())
fitp
fitnb <- gllvm(y=spider$abund, family = "negative.binomial")
fitnb

# Based on AIC, NB distribution suits better. How about residual analysis:
# NOTE THAT: The package uses randomized quantile residuals so each time you plot the residuals, they look a little different. 
# Fit a GLLVM to data
par(mfrow = c(1,2))
plot(fitp, which = 1:2)
plot(fitnb, which = 1:2)
# The fan-shape in the residual plot for Poisson fit is an indication of overdispersion, NB suits better

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

# GLLVM with two latent variables can be used as a model-based approach to unconstrained ordination, as considered at the first day of the workshop.


### E3. Fit GLLVM with environmental variables `soil.dry` and `reflection` to the data with suitable number of latent variables.  

# We can extract the two columns from the environmental variable matrix or define the model using formula.  
head(spider$x)
# `soil.dry` and `reflection` are in columns 1 and 6
X <- spider$x[,c(1,6)]
fitx1 <- gllvm(spider$abund, X, family = "negative.binomial", num.lv = 1)
fitx2 <- gllvm(spider$abund, X, family = "negative.binomial", num.lv = 2)
fitx3 <- gllvm(spider$abund, X, family = "negative.binomial", num.lv = 3)
AIC(fitx1)
AIC(fitx2)
AIC(fitx3)
# Or alternatively using formula:
fitx1 <- gllvm(spider$abund, spider$x, formula = ~soil.dry + reflection, family = "negative.binomial", num.lv = 1)
fitx1
# Model with one latent variable gave the lowest AIC value.



### E4. Explore the model fit. Find the coefficients for environmental covariates.  

# Estimated parameters can be obtained with `coef()` function. Confidence intervals for parameters are obtained with `confint()`.
coef(fitx1)
# Coefficients for covariates are named as `Xcoef`
# Confidence intervals for these coefficients:
confint(fitx1, parm = "Xcoef")
# The first 12 intervals are for soil.dry and next 12 for reflection




#######################################################
# Problems? See hints:
# I have problems in model fitting. My model converges to infinity or local maxima
# GLLVMs are complex models where starting values have a big role. Choosing a different starting value method (see argument `starting.val`) or use multiple runs and pick up the one giving highest log-likelihood value using argument `n.init`. More variation to the starting points can be added with `jitter.var`.

# My results does not look the same as in answers:
# The results may not be exactly the same as in the answers, as the initial values for each model fit are slightly different, so the results may also differ slightly.
